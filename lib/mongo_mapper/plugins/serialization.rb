require 'active_support/json'

module MongoMapper
  module Plugins
    module Serialization
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::Serializers::JSON
        # Re-include this here otherwise we get run over by ActiveModel serialization
        include SerializableHash
        extend FromJson
      end

      module SerializableHash
        def serializable_hash options={}
          options ||= {}
          unless options[:only]
            methods = [options.delete(:methods)].flatten.compact
            methods << :id
            options[:methods] = methods.uniq
          end

          except = [options.delete(:except)].flatten.compact
          except << :_id
          options[:except] = except

          hash = super(options)
          hash.each do |key, value|
            if value.is_a?(Array)
              hash[key] = value.map do |item|
                item.respond_to?(:serializable_hash) ? item.serializable_hash(options) : item
              end
            elsif value.respond_to?(:serializable_hash)
              hash[key] = value.serializable_hash(options)
            end
          end
        end
      end

      module FromJson
        def from_json(json)
          self.attributes = ActiveSupport::JSON.decode(json)
          self
        end
      end

    end
  end
end