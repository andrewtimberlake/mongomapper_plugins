module MongoMapper
  module Plugins
    module VersionedUpdate
      def self.configure(mod)
        mod.class_eval {
          key :_version, Integer, :default => 1
        }
      end

      module ClassMethods
        def versioned_update
          plugin MongoMapper::Plugins::VersionedUpdate
        end
      end

      module InstanceMethods
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

      module Addition
        def self.included(model)
          model.plugin VersionedUpdate
        end
      end
    end
  end
end

MongoMapper::Document.append_inclusions MongoMapper::Plugins::VersionedUpdate::Addition
