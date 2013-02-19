module MongoMapper
  module Plugins
    module VersionedUpdate
      extend ActiveSupport::Concern

      module ClassMethods
        def versioned_update
          include MongoMapper::Plugins::VersionedUpdate::OverriddenMethods
          key :_version, Integer, :default => 1
        end
      end

      module OverriddenMethods
        private
        # Overriding save_to_collection in lib/mongo_mapper/plugins/querying.rb
        def save_to_collection(options={})
          if persisted?
            @_new = false
            old_version = self._version
            self._version += 1
            ret = collection.update({:_id => _id, :_version => old_version}, to_mongo)
            if ret['n'] == 0
              self._version -= 1
              raise InvalidVersion
            end
            ret['err'].nil?
          else
            super
          end
        end
      end

      class InvalidVersion < StandardError; end
    end
  end
end

MongoMapper::Document.plugin MongoMapper::Plugins::VersionedUpdate
