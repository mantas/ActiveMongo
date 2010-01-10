module ActiveMongo
  module Indexes
    module ClassMethods
      def ensure_index(*attr)
        fields = attr[0]
        
        options = attr[1]
        unique = options[:unique] if options.class == Hash
        
        unique ||= false
        
        self.collection.create_index fields, :unique => unique
      end      
      
    end
  end
end