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
        args = [
          :"#{a.name}_skeleton",
          -> { a.klass.select a.klass.skeleton_arel_columns },
          class_name: a.class_name,
          foreign_key: a.foreign_key,
          foreign_type: a.foreign_type
        ]

        self.send a.macro, *args
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
      all.includes_values = all.includes_values.map do |v|
        s = :"#{v}_skeleton"
        ref = reflect_on_association(s) || reflect_on_association(v)
        acolumns << arel_table[ref.foreign_key] if acolumns && !skeleton_columns.include?(ref.foreign_key.to_sym)
        ref.name
      end
      acolumns ? select(acolumns) : all
    end

    def naked
      f = all.arel.projections.first
      cnames = f.respond_to?(:name) && f.name == '*' ? column_names : all.arel.projections
      records = pluck(all.arel.projections).map{|rec| Hash[*cnames.zip(rec).flatten(1)]}

      assoc_recs = {}
      all.includes_values.each do |aname|
        assoc = self.reflect_on_association aname
        ids = records.map{|r| r[assoc.foreign_key]}.uniq
        assoc_recs[aname.to_s.sub('_skeleton','').to_sym] = Hash[
          (assoc.scope ? assoc.scope.call : assoc.klass).where(id: ids).naked.map{|r| [r['id'], r]}
        ]
      end

      records.map do |attrs|
        assocs = {}
        assoc_recs.each do |k,v|
          assocs[k.to_s] = v[attrs[self.reflect_on_association(k).foreign_key]]
        end
        attrs = assocs.merge(simple_obj(attrs.merge(assocs)))
      end
    end
  end

end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
