# via: http://stackoverflow.com/a/2329394/313561
module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here
  #def foo
     #"foo"
  #end

  # add your static(class) methods here
  module ClassMethods

    def bones args=false
      args ? bones_init(args) : bones_query
    end

    def bones_init args={}
      cattr_accessor :bones_columns
      cattr_accessor :bones_arel_columns

      columns = args[:columns] || :all
      assocs = args[:assocs] || []

      self.bones_columns = (columns == :all ? column_names : columns).map{|c| c.to_sym}
      self.bones_arel_columns = bones_columns.map{|c| arel_table[c]}

      assocs.each do |name|
        assoc = reflect_on_association name

        options = assoc.options.merge({
          class_name:   assoc.class_name,
          foreign_key:  assoc.foreign_key,
        })
        options[:foreign_type] = assoc.foreign_type if assoc.macro == :belongs_to

        scope = -> {
          query = assoc.scope ? assoc.klass.instance_eval(&assoc.scope) : assoc.klass.all
          query.select(assoc.klass.bones_arel_columns)
        }

        send assoc.macro, *[:"#{assoc.name}_bones", scope, options]

        alias_method "#{assoc.name}_flesh", assoc.name
        define_method(assoc.name) do
          if self.association(assoc.name.to_sym).loaded? || !self.association(:"#{assoc.name}_bones").loaded?
            self.send("#{assoc.name}_flesh")
          else
            self.send("#{assoc.name}_bones")
          end
        end
      end
    end

    def bones_query
      acolumns = defined?(bones_arel_columns) ? bones_arel_columns : false
      # This must use map! rather than v = v.map because assignment doesn't work
      # correctly within this method even though it works outside of it. No idea.
      all.includes_values.map! do |v|
        s = :"#{v}_bones"
        ref = reflect_on_association(s) || reflect_on_association(v)
        acolumns << arel_table[ref.foreign_key.to_sym] if acolumns && !bones_columns.include?(ref.foreign_key.to_sym)
        ref.name
      end
      acolumns ? select(acolumns) : all
    end

    def bare
      # Dupe and clear includes_values else pluck() will do a join on them
      includes = all.includes_values.dup
      all.includes_values.clear

      columns = all.arel.projections.first.name == '*' ? column_names : all.arel.projections.map {|c| c.name.to_s }
      records = pluck(all.arel.projections).map {|values| Hash[columns.zip(values)] }

      assoc_recs = {}
      includes.each do |aname|
        assoc = self.reflect_on_association aname
        ids = records.map{|r| r[assoc.foreign_key]}.uniq
        assoc_recs[aname.to_s.sub('_bones','').to_sym] = Hash[
          (assoc.scope ? assoc.scope.call : assoc.klass).where(id: ids).bare.map{|r| [r['id'], r]}
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

def bones_bm l=100
  ActiveRecord::Base.logger.silence do
    Benchmark.ips(12) do |x|
      x.report('Full:')       { Post.limit(l).includes(:user, :page).to_a }
      x.report('Bones:')      { Post.limit(l).includes(:user, :page).to_a }
      x.report('Bare:')       { Post.limit(l).includes(:user, :page).bare }
      x.report('Bare Bones:') { Post.limit(l).includes(:user, :page).bones.bare }
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
