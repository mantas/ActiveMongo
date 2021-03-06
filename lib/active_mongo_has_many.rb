module ActiveMongo
  module HasMany
    module ClassMethods
      def has_many(name, attrs = {})
        internal_has_manies_set(name, attrs)
      end
      
      def internal_has_manies_set(name, attrs)
        @@internal_has_manies ||= {}
        
        name = self.name.to_s+'___'+name.to_s
        
        @@internal_has_manies[name.to_sym] = attrs if @@internal_has_manies[name.to_sym].nil?
      end
    
      def internal_has_manies_get(name)
        @@internal_has_manies ||= {}
        
        name = self.name.to_s+'___'+name.to_s
        
        @@internal_has_manies[name.to_sym]
      end
      
    end
      
    module InstanceMethods
      def has_many_hit(name, attrs)
        return false if self.new_record?
        
        attrs[:class_name] ||= name.to_s.classify
        attrs[:foreign_key] ||= self.class.name.to_s.singularize.underscore+"_id"
        
        return eval(attrs[:class_name]).with_scope(attrs[:foreign_key] => self._id )
      end
    end
  end
end