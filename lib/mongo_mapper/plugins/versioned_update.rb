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
          def update(options={})
            version = self._version
            self._version += 1
            ret = collection.update({:_id => _id, :_version => version},
                                    to_mongo,
                                    :safe => true)
            if ret['n'] == 0
              self._version -= 1
              raise InvalidVersion
            end
            ret['err'].nil?
          end
      end

      class InvalidVersion < StandardError; end
    end
  end
end

MongoMapper::Document.plugin MongoMapper::Plugins::VersionedUpdate
