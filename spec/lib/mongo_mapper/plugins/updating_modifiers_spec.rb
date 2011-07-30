require 'spec_helper'
require 'mongo_mapper/plugins/updating_modifiers'

class Address
  include MongoMapper::EmbeddedDocument
  key :line1, String
  key :parcels_sent, Integer, :default => 0
end

class Person
  include MongoMapper::Document
  key :name, String
  key :dependants, Integer, :default => 0
  key :address, Address
  key :friends, Array, :type_cast => BSON::ObjectId
end

MongoMapper::Document.plugin MongoMapper::Plugins::UpdatingModifiers

module MongoMapper
  module Plugins
    describe UpdatingModifiers do

      let(:person) { Person.create(:name => 'John Smith', :address => Address.new(:line1 => 'Here')) }

      context "#set" do
        it "should update a simple key with set" do
          person.set(:name => 'Jane Smith')
          person.name.should == 'Jane Smith'

          person.reload
          person.name.should == 'Jane Smith'
        end

        it "should update a custom key" do
          person.set('address.line1' => 'There')
          person.address.line1.should == 'There'

          person.reload
          person.address.line1.should == 'There'
        end
      end

      context "#increment" do
        context "from a 0 base" do
          it "should update a simple key with increment" do
            person.increment(:dependants => 1)
            person.dependants.should == 1

            person.reload
            person.dependants.should == 1
          end

          it "should update a custom key" do
            person.increment('address.parcels_sent' => 2)
            person.address.parcels_sent.should == 2

            person.reload
            person.address.parcels_sent.should == 2
          end
        end

        context "from a defined base" do
          before do
            person.dependants = 2
            person.address.parcels_sent = 1
            person.save
          end

          it "should update a simple key with increment" do
            person.increment(:dependants => 2)
            person.dependants.should == 4

            person.reload
            person.dependants.should == 4
          end

          it "should update a custom key" do
            person.increment('address.parcels_sent' => 1)
            person.address.parcels_sent.should == 2

            person.reload
            person.address.parcels_sent.should == 2
          end
        end
      end

      context "#decrement" do
        context "from a 0 base" do
          it "should update a simple key with decrement" do
            person.decrement(:dependants => 1)
            person.dependants.should == -1

            person.reload
            person.dependants.should == -1
          end

          it "should update a custom key" do
            person.decrement('address.parcels_sent' => 2)
            person.address.parcels_sent.should == -2

            person.reload
            person.address.parcels_sent.should == -2
          end
        end

        context "from a defined base" do
          before do
            person.dependants = 2
            person.address.parcels_sent = 10
            person.save
          end

          it "should update a simple key with decrement" do
            person.decrement(:dependants => 2)
            person.dependants.should == 0

            person.reload
            person.dependants.should == 0
          end

          it "should update a custom key" do
            person.decrement('address.parcels_sent' => 1)
            person.address.parcels_sent.should == 9

            person.reload
            person.address.parcels_sent.should == 9
          end
        end
      end

      context "#push" do
        let(:friend) { Person.create(:name => "John Doe") }

        it "should add an element to an empty array" do
          person.push(:friends => friend.id)
          person.should have(1).friend

          person.reload
          person.should have(1).friend
        end

        it "should add an element to an empty array" do
          person.friends = [Person.create(:name => 'Test').id]
          person.save

          person.push(:friends => friend.id)
          person.should have(2).friend

          person.reload
          person.should have(2).friend
        end
      end

      context "#pull" do
        let(:friend) { Person.create(:name => "John Doe") }

        before do
          person.friends << friend.id
          person.save
        end

        it "should remove an element from an array" do
          person.should have(1).friend

          person.pull(:friends => friend.id)
          person.should have(0).friends

          person.reload
          person.should have(0).friends
        end

        it "should leave an array untouched if the pull doesn't match anything" do
          person.should have(1).friend

          person.pull(:friends => Person.create(:name => 'Test').id)
          person.should have(1).friend

          person.reload
          person.should have(1).friend
        end
      end

      context "#push_uniq" do
        let(:friend) { Person.create(:name => "John Doe") }

        before do
          person.friends << friend.id
          person.save
        end

        it "should remove an element from an array" do
          person.should have(1).friend

          person.push_uniq(:friends => friend.id)
          person.should have(1).friends

          person.reload
          person.should have(1).friends
        end

        it "should leave an array untouched if the pull doesn't match anything" do
          person.should have(1).friend

          person.push_uniq(:friends => Person.create(:name => 'Test').id)
          person.should have(2).friends

          person.reload
          person.should have(2).friends
        end
      end
    end
  end
end
