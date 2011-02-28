require 'mongo_mapper'

RSpec.configure do |config|
  config.before(:all) do
    MongoMapper.connection = Mongo::Connection.new('localhost')
    MongoMapper.database = 'mongomapper_plugins_test'
  end

  config.after(:each) do
    MongoMapper.database.collections.each { |col| col.remove }
  end

  config.after(:all) do
    MongoMapper.connection.drop_database 'mongomapper_plugins_test'
  end
end
