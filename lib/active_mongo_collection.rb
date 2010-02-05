ActiveMongo::Base.class_eval do
      def self.collection_name
        (self.name || @name).downcase.pluralize
      end

      def self.collection
        $mongo_db.collection(collection_name)
      end

      def self.count(attrs = {})
        attrs = self.scope.merge(attrs) if self.scope
        
        if attrs.any?
          self.collection.find(attrs).count
        else
          self.collection.count
        end
      end

      def self.destroy_all(attrs = {})
        attrs = self.scope.merge(attrs) if self.scope
        
        
        if attrs.any?
          self.collection.remove(attrs)
        else
          self.collection.remove()
        end
      end

      # def self.find(attrs = {})
      def self.find(selector = nil, *attrs)
        if selector.class == String || selector.class == Mongo::ObjectID
          id = Mongo::ObjectID.from_string(selector) if selector.class == String
          
          id ||= selector
          
          obj = self.collection.find_one(id)
          
          model = eval(self.name || @name).new

          obj.each {|key, value| model.set_var(key, value)  }
          
          return model
        else
          selector = self.scope.merge(selector || {}) if self.scope
          
          ret = []
          
          selector ||= {}
          
          selector.each do |key, value|
            if key.to_s.match(/\_id$/) && value.class == String
              selector[key] = Mongo::ObjectID.from_string(value)
            end
          end
          
          self.collection.find(selector, attrs[0] || {}).to_a.map do |obj|
            model = eval(self.name || @name).new

            obj.each {|key, value| model.set_var(key, value)  }

            ret.push model
          end

          return ret
        end
      end  
      
      def self.extended(klass)
        class << klass
          alias __old_new new
        end
      end    
      
      self.extended(self)  
      
      def self.new(*attrs)
        attrs = attrs[0]
        
        eval(self.name || @name).__old_new(attrs, :scope => self.scope)
      end
      
      def self.method_missing(m, *attrs, &block)
        if self.internal_named_scopes_get(m)
          return self.named_scope_hit(m)
        end
        
        super
      end
end