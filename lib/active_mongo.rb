require 'mongo'
require 'lib/active_mongo_uniquenesss'
include Mongo

config = YAML::load(File.open("#{RAILS_ROOT}/config/mongo.yml"))[Rails.env]

$mongo_conn = Connection.new(config["host"], config["port"], :pool_size => 5, :timeout => 5)
$mongo_db = $mongo_conn.db(config["database"])

require 'lib/active_mongo_has_many'

module ActiveMongo
  
  class Base
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveMongo::HasMany::ClassMethods
    include ActiveMongo::HasMany::InstanceMethods
    
    class << self; attr_accessor :scope; end
  end
end


require 'lib/active_mongo_collection'
require 'lib/active_mongo_instance'
require 'lib/active_mongo_scope'