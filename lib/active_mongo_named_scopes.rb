module ActiveMongo
  module NamedScopes
    module ClassMethods
      def named_scope(name, attrs = {})
        internal_named_scopes_set(name, attrs)
      end
      
      def internal_named_scopes_set(name, attrs)
        @@internal_named_scopes ||= {}
        
        @@internal_named_scopes[name.to_sym] = attrs if @@internal_named_scopes[name].nil?
      end
    
      def internal_named_scopes_get(name)
        @@internal_named_scopes ||= {}
        
        @@internal_named_scopes[name.to_sym]
      end
      
      def named_scope_hit(name)
        return eval(self.name).with_scope( @@internal_named_scopes[name] )
      end
    end
  end
end