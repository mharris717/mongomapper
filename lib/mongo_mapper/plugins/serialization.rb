require 'active_support/json'

module MongoMapper
  module Plugins
    module Serialization
      module Json
        extend ActiveSupport::Concern
        include ActiveModel::Serializers::JSON

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

=begin
        def from_json(json)
          self.attributes = ActiveSupport::JSON.decode(json)
          self
        end

        class JsonSerializer < Serializer
          def serialize
            serializable_record.to_json
          end
        end

        private
          def apply_to_json_defaults(options)

          end
=end
      end
      
      module InstanceMethods
        def self.included(model)
          model.class_eval do
            include ActiveModel::Serialization
            include Json
          end
        end
      end
    end
  end
end