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

      self.skeleton_columns = (columns == :all ? column_names : columns)
      assocs.each do |name|
        a = self.reflect_on_association name
        args = [
          "#{a.name}_skeleton".to_sym,
          :class_name => a.class_name,
          :foreign_key => a.foreign_key,
          :foreign_type => a.foreign_type,
          :select => a.klass.skeleton_columns
        ]
        if !self.skeleton_columns.include?(a.foreign_key.to_sym)
          self.skeleton_columns << a.foreign_key.to_sym
        end
        self.send a.macro, *args
      end
    end

    def skeletal
      rel = select(skeleton_columns)
      rel.includes_values = rel.includes_values.map do |v|
        s = "#{v}_skeleton".to_sym
        self.reflect_on_association(s).blank? ? v : s
      end
      rel
    end

    def lightning
      connection.select_all(skeletons.arel).each do |attrs|
        attrs.each_key do |attr|
          attrs[attr] = type_cast_attribute(attr, attrs)
        end
      end
    end
  end

end

# include the extension 
ActiveRecord::Base.send(:include, ActiveRecordExtension)
