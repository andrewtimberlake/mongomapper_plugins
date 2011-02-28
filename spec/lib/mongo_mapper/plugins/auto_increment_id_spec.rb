require 'spec_helper'
require 'mongo_mapper/plugins/auto_increment_id'

module MongoMapper
  module Plugins
    describe AutoIncrementId do
      let (:model_class) do
        klass = Class.new
        klass.class_eval do
          include MongoMapper::Document
          auto_increment_id
        end
        klass
      end

      it "should generate a new id when creating" do
        model = model_class.create!
        model.id.should > 0

        model2 = model_class.create!
        model2.id.should == model.id + 1

        model3 = model_class.create!
        model3.id.should == model2.id + 1
      end
    end
  end
end
