# via: http://stackoverflow.com/a/2329394/313561
module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here
  #def foo
     #"foo"
  #end

  # add your static(class) methods here
  module ClassMethods

    def skeleton args={}
      columns = args[:columns] || :all
      assocs = args[:assocs] || []

      cattr_accessor :skeleton_columns
      cattr_accessor :skeleton_arel_columns

      self.skeleton_columns = (columns == :all ? column_names : columns).map{|c| c.to_sym}
      self.skeleton_arel_columns = skeleton_columns.map{|c| arel_table[c]}

      assocs.each do |name|
        a = reflect_on_association name
        send a.macro, *[
          :"#{a.name}_skeleton",
          -> { a.klass.select a.klass.skeleton_arel_columns },
          class_name:   a.class_name,
          foreign_key:  a.foreign_key,
          foreign_type: a.foreign_type
        ]

        alias_method "#{a.name}_flesh", a.name
        define_method(a.name) do
          if self.association(a.name.to_sym).loaded? || !self.association(:"#{a.name}_skeleton").loaded?
            self.send("#{a.name}_flesh")
          else
            self.send("#{a.name}_skeleton")
          end
        end
      end
    end

    def skeletal
      acolumns = defined?(skeleton_arel_columns) ? skeleton_arel_columns : false
      # This must use map! rather than v = v.map because assignment doesn't work
      # correctly within this method even though it works outside of it. No idea.
      all.includes_values.map! do |v|
        s = :"#{v}_skeleton"
        ref = reflect_on_association(s) || reflect_on_association(v)
        acolumns << arel_table[ref.foreign_key.to_sym] if acolumns && !skeleton_columns.include?(ref.foreign_key.to_sym)
        ref.name
      end
      acolumns ? select(acolumns) : all
    end

    def naked
      # Taken from ActiveRecord's pluck()
      # https://github.com/rails/rails/blob/master/activerecord/lib/active_record/relation/calculations.rb#L154
      klass = self
      result = klass.connection.select_all(all.arel)
      columns = result.columns.map do |key|
        klass.column_types.fetch(key) {
          result.column_types.fetch(key) {
            Class.new { def type_cast(v); v; end }.new
          }
        }
      end

      result = result.map do |attributes|
        values = klass.initialize_attributes(attributes).values
        record = {}
        columns.zip(values).map do |column, value|
          # For TimeZoneConversion column type because for some reason it won't give us direct access to @column. TODO - cleanup
          c = column.instance_variable_get(:@column) || column
          record[c.name] = column.type_cast(value)
        end
        record
      end

      assoc_recs = {}
      all.includes_values.each do |aname|
        assoc = self.reflect_on_association aname
        ids = result.map{|r| r[assoc.foreign_key]}.uniq
        assoc_recs[aname.to_s.sub('_skeleton','').to_sym] = Hash[
          (assoc.scope ? assoc.scope.call : assoc.klass).where(id: ids).naked.map{|r| [r['id'], r]}
        ]
      end

      result.map do |attrs|
        assocs = {}
        assoc_recs.each do |k,v|
          assocs[k.to_s] = v[attrs[self.reflect_on_association(k).foreign_key]]
        end
        attrs = assocs.merge(simple_obj(attrs.merge(assocs)))
      end
    end
  end

end

def skeleton_bm l=100, n=20
  ll = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil

  Benchmark.bmbm(15) do |x|
    x.report 'Full:' do
      n.times do
        Post.limit(l).includes(:user, :page).map {|p| p.simple_obj }
      end
    end
    x.report 'Skeletal:' do
      n.times do
        Post.limit(l).includes(:user, :page).skeletal.map {|p| p.simple_obj }
      end
    end
    x.report 'Naked:' do
      n.times do
        Post.limit(l).includes(:user, :page).naked
      end
    end
    x.report 'Naked Skeletal:' do
      n.times do
        Post.limit(l).includes(:user, :page).skeletal.naked
      end
    end
  end

  ActiveRecord::Base.logger = ll
  puts "\n"
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
