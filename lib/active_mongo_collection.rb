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

      def self.find(attrs = {})
        if attrs.class == String
          id = Mongo::ObjectID.from_string(attrs[0])
          
          return self.collection.find_one(id)
        else
          attrs = self.scope.merge(attrs) if self.scope
          
          ret = []
          
          self.collection.find(attrs).to_a.map do |obj|
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
          def new(*args, &blk)
            __old_new(*args, &blk).freeze
          end
        end
      end    
      
      self.extended(self)  
      
      def self.new(*attrs)
        attrs = attrs[0]
        
        if self.scope
          attrs ||= {}
          attrs.merge!(self.scope)   
        end
        
        eval(self.name || @name).__old_new(attrs)
      end
end