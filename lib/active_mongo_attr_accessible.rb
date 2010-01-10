module ActiveMongo
  module AttrAccessible
    module ClassMethods
      def attr_accessible(*input)
        @@internal_attr_accessible = []
        
        input.each do |field|
          @@internal_attr_accessible.push(field.to_sym).uniq!
        end
      end      
      
      def attr_accessible_get
        @@internal_attr_accessible || []
      end
      
      def attr_clear(*input)
        @@internal_attr_clear = []
        
        input.each do |field|
          @@internal_attr_clear.push(field.to_sym).uniq!
        end
      end      
      
      def attr_accessible_get
        @@internal_attr_accessible || []
      end
      
      def attr_clear_get
        @@internal_attr_clear || []
      end
      
    end
  end
end