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
      # Dupe and clear includes_values else pluck() will do a join on them
      includes = all.includes_values.dup
      all.includes_values.clear

      columns = all.arel.projections.first.name == '*' ? column_names : all.arel.projections.map {|c| c.name.to_s }
      records = pluck(all.arel.projections).map {|values| Hash[columns.zip(values)] }

      assoc_recs = {}
      includes.each do |aname|
        assoc = self.reflect_on_association aname
        ids = records.map{|r| r[assoc.foreign_key]}.uniq
        assoc_recs[aname.to_s.sub('_skeleton','').to_sym] = Hash[
          (assoc.scope ? assoc.scope.call : assoc.klass).where(id: ids).naked.map{|r| [r['id'], r]}
        ]
      end

      records.map do |attrs|
        assoc_recs.each do |k,v|
          attrs[k.to_s] = v[attrs[self.reflect_on_association(k).foreign_key]]
        end
        attrs
        #attrs = assocs.merge(simple_obj(attrs))
      end
    end
  end

end

def skeleton_bm l=100
  ActiveRecord::Base.logger.silence do
    Benchmark.ips(15) do |x|
      x.report('Full:')           { Post.limit(l).includes(:user, :page).to_a }
      x.report('Skeletal:')       { Post.limit(l).includes(:user, :page).to_a }
      x.report('Naked:')          { Post.limit(l).includes(:user, :page).naked }
      x.report('Naked Skeletal:') { Post.limit(l).includes(:user, :page).skeletal.naked }
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
