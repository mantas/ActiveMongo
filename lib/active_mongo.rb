module ActiveMongo
  class Railtie < Rails::Railtie
    railtie_name :active_mongo
    initializer "active_mongo.initialize_active_mongo" do |app|
      require 'active_mongo_start'
    end
  end
end
