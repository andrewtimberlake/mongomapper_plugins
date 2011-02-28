module MongoMapper
  module Plugins
    module UpdatingModifiers
      def self.configure(mod)
      end

      module InstanceMethods
        def set(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            obj.send("#{method}=", value)
          end
          super
        end

        def increment(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            val = obj.send(method)
            obj.send("#{method}=", val + value)
          end
          super
        end

        def decrement(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            val = obj.send(method)
            obj.send("#{method}=", val - value)
          end
          super
        end

        def push(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            obj = obj.send(method)
            obj.push value
          end
          super
        end

        def pull(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            obj = obj.send(method)
            obj.delete_if { |e| e == value }
          end
          super
        end

        def add_to_set(hash)
          hash.each do |key, value|
            obj, method = get_obj_and_method(key)
            obj = obj.send(method)
            obj.push(value) unless obj.include?(value)
          end
          super
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
      end

      module Addition
        def self.included(model)
          model.plugin UpdatingModifiers
        end
      end
    end
  end
end
