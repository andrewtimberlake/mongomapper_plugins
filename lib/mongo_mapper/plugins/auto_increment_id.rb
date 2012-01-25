module MongoMapper
  module Plugins
    module AutoIncrementId
      extend ActiveSupport::Concern

      module ClassMethods
        def auto_increment_id
          key :_id, Integer

          before_create :generate_document_id
        end
      end

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
  end
end

MongoMapper::Document.plugin MongoMapper::Plugins::AutoIncrementId
