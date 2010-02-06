module ActiveMongo
  module AttrAccessible
    module ClassMethods
      def attr_accessible(*input)
        @@internal_attr_accessible ||= {}
        @@internal_attr_accessible[self.name] ||= []
        
        input.each do |field|
          @@internal_attr_accessible[self.name].push(field.to_sym).uniq!
        end
      end      
      
      def attr_accessible_get
        @@internal_attr_accessible[self.name] || []
      end
      
      def attr_clear(*input)
        @@internal_attr_clear ||= {}
        @@internal_attr_clear[self.name] ||= []
        
        input.each do |field|
          @@internal_attr_clear[self.name].push(field.to_sym).uniq!
        end
      end      
      
      def attr_accessible_get
        @@internal_attr_accessible[self.name] || []
      end
      
      def attr_clear_get
        @@internal_attr_clear[self.name] || []
      end
      
    end
  end
end