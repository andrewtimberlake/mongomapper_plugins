module MongoMapper
  module Plugins
    module UpdatingModifiers
      extend ActiveSupport::Concern

      def self.configure(mod)
      end

      def set(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          obj.send("#{method}=", value)
        end
        super hash_to_mongo(hash)
      end

      def increment(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          val = obj.send(method)
          obj.send("#{method}=", val + value)
        end
        super hash_to_mongo(hash)
      end

      def decrement(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          val = obj.send(method)
          obj.send("#{method}=", val - value)
        end
        super hash_to_mongo(hash)
      end

      def push(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          obj = obj.send(method)
          obj.push value
        end
        super hash_to_mongo(hash)
      end

      def pull(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          obj = obj.send(method)
          obj.delete_if { |e| e == value }
        end
        super hash_to_mongo(hash)
      end

      def add_to_set(hash)
        hash.each do |key, value|
          obj, method = get_obj_and_method(key)
          obj = obj.send(method)
          obj.push(value) unless obj.include?(value)
        end
        super hash_to_mongo(hash)
      end
      alias push_uniq add_to_set

      private
      def get_obj_and_method(key)
        children = key.to_s.split(/\./)
        method = children.pop

        obj = self
        children.each do |child|
          obj = obj.send(child)
        end

        [obj, method]
      end

      def hash_to_mongo(arg)
        if arg.is_a?(Hash)
          keys = arg.keys
          keys.each do |k|
            arg[k] = hash_to_mongo(arg[k])
          end
          arg
        else
          arg && arg.respond_to?(:to_mongo) ? arg.to_mongo : arg
        end
      end
    end
  end
end
