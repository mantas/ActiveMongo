require 'active_support/core_ext/object/blank'

module ActiveModel
  module Validations
    class UniquenessValidator < EachValidator
      def validate(record)
        attribute = attributes[0]
        
        query = {}
        query[:_id] = {"$ne" => record._id}
        query[attribute] = record.get_var(attribute) 
        
        options[:scope].each do |scope|
          query[scope] = record.get_var(scope)
        end
        
        int = record.class.count( query )
        
        record.errors.add(attribute, options[:message]) if int > 0
      end
    end
 
    module ClassMethods
      
      def validates_uniqueness_of(*attr_names)
        options = _merge_attributes(attr_names)
        options[:message] ||= "is taken"
        options[:scope] ||= []
        validates_with UniquenessValidator, options
      end
    end
  end
end