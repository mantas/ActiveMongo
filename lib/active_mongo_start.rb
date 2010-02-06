require 'mongo'
require 'active_mongo_uniquenesss'
include Mongo

config = YAML::load(File.open("#{RAILS_ROOT}/config/mongo.yml"))[Rails.env]

$mongo_conn = Connection.new(config["host"], config["port"], :pool_size => 10, :timeout => 2)
$mongo_db = $mongo_conn.db(config["database"])

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      $mongo_db.connect_to_master # Call db.connect_to_master to reconnect here
    end
  end
end

if config["user"]
  if !$mongo_db.authenticate(config["user"], config["password"])
    puts "Wrong MongoDB user and/or password!!!"
  end
end

require 'active_mongo_has_many'
require 'active_mongo_attr_accessible'
require 'active_mongo_indexes'
require 'active_mongo_named_scopes'

module ActiveMongo
  
  class Base
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Callbacks
    extend ActiveModel::Callbacks
    extend ActiveMongo::Indexes::ClassMethods
    extend ActiveMongo::AttrAccessible::ClassMethods
    extend ActiveMongo::NamedScopes::ClassMethods
    extend ActiveMongo::HasMany::ClassMethods
    include ActiveMongo::HasMany::InstanceMethods
    
    define_model_callbacks :create, :save, :update
    define_model_callbacks :initializer, :only => :after
    
    class << self; attr_accessor :scope; end
    
    def self.extended(klass)
      class << klass
        alias __old_name name
        def name(*args, &blk)
          return @name || self.__old_name
        end
      end
    end    
    
    self.extended(self)  
    
  end
end


require 'active_mongo_collection'
require 'active_mongo_instance'
require 'active_mongo_scope'