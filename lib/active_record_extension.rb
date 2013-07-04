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

      self.skeleton_columns = (columns == :all ? column_names : columns).map{|c| c.to_sym}
      assocs.each do |name|
        a = self.reflect_on_association name
        args = [
          :"#{a.name}_skeleton",
          -> { select a.klass.skeleton_columns },
          class_name: a.class_name,
          foreign_key: a.foreign_key,
          foreign_type: a.foreign_type
        ]
        if !self.skeleton_columns.include?(a.foreign_key.to_sym)
          self.skeleton_columns << a.foreign_key.to_sym
        end
        self.send a.macro, *args
        alias_method "#{a.name}_flesh", a.name
        define_method(a.name) do
          if self.association(a.name.to_sym).loaded? || !self.association("#{a.name}_skeleton".to_sym).loaded?
            self.send("#{a.name}_flesh")
          else
            self.send("#{a.name}_skeleton")
          end
        end
      end
    end

    def skeletal
      rel = select(defined?(skeleton_columns) ? skeleton_columns : column_names)
      rel.includes_values = rel.includes_values.map do |v|
        s = "#{v}_skeleton".to_sym
        self.reflect_on_association(s).blank? ? v : s
      end
      rel
    end

    def naked
      records = pluck all.arel.projections

      assoc_recs = {}
      all.includes_values.each do |aname|
        assoc = self.reflect_on_association aname
        ids = records.map{|r| r[assoc.foreign_key]}.uniq
        assoc_recs[aname.to_s.sub('_skeleton','').to_sym] = Hash[
          assoc.klass.select(assoc.options[:select]).where(:id => ids).naked.map{|r| [r['id'], r]}
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
