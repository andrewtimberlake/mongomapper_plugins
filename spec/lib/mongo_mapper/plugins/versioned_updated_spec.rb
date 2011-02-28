require 'spec_helper'
require 'mongo_mapper/plugins/versioned_update'

module MongoMapper
  module Plugins
    describe VersionedUpdate do
      let (:model_class) do
        klass = Class.new
        klass.class_eval do
          include MongoMapper::Document
          set_collection_name :test
        end
        klass
      end

      before do
        model_class.class_eval do
          versioned_update
        end
      end

      it "should have a _version key" do
        model_class.keys.should include('_version')
      end

      it "should increment the _version key on every save" do
        model = model_class.create
        model._version.should == 1
        model.save
        model._version.should == 2
      end

      it "should not allow a save if the model has changed since loading" do
        model1 = model_class.create
        model2 = model_class.find model1.id

        model1.save
        expect { model2.save }.to raise_error(MongoMapper::Plugins::VersionedUpdate::InvalidVersion)
      end

      it "should have the same version number if the save fails" do
        model1 = model_class.create
        model2 = model_class.find model1.id

        model1.save
        begin
          model2.save
        rescue
        end
        model2._version.should == 1
      end
    end
  end
end
