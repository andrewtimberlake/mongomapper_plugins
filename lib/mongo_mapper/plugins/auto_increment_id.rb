module MongoMapper
  module Plugins
    module AutoIncrementId
      module ClassMethods
        def auto_increment_id
          key :_id, Integer

          after_create :generate_document_id
        end
      end

      module InstanceMethods
        private
          def generate_document_id(options={})
            while true
              oldest_number = self.class.fields(:_id).sort([[:_id, :descending]]).first.try(:id)
              self.id = oldest_number.to_i + 1
              begin
                break if collection.insert({:_id => id}, :safe => true)
              rescue Mongo::OperationFailure => e
                #Ignored, trying to get the next key
              end
            end
          end
      end

      module Addition
        def self.included(model)
          model.plugin AutoIncrementId
        end
      end
    end
  end
end

MongoMapper::Document.append_inclusions MongoMapper::Plugins::AutoIncrementId::Addition
