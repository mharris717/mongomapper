module MongoMapper
  module EmbeddedDocument
    extend Support::DescendantAppends
    extend ActiveSupport::Concern
    included do
      extend Plugins

      plugin Plugins::Associations
      plugin Plugins::Clone
      plugin Plugins::Descendants
      plugin Plugins::Equality
      plugin Plugins::Inspect
      plugin Plugins::Keys
      plugin Plugins::Logger
      plugin Plugins::Protected
      plugin Plugins::Rails
      plugin Plugins::Serialization
      plugin Plugins::Validations

      attr_accessor :_root_document, :_parent_document
    end

    module ClassMethods
      def embeddable?
        true
      end

      def embedded_in(owner_name)
        define_method(owner_name) { _parent_document }
      end
    end

    module InstanceMethods
      def initialize(attrs={}, from_database=false)
        unless attrs.nil?
          provided_keys = attrs.keys.map { |k| k.to_s }
          unless provided_keys.include?('_id') || provided_keys.include?('id')
            write_key :_id, Mongo::ObjectID.new
          end
        end

        assign_type_if_present

        if from_database
          @new = false
          self.attributes = attrs
        else
          @new = true
          assign(attrs)
        end
      end
      
      def save(options={})
        if result = _root_document.try(:save, options)
          @new = false
        end
        result
      end

      def save!(options={})
        if result = _root_document.try(:save!, options)
          @new = false
        end
        result
      end
    end # InstanceMethods
  end # EmbeddedDocument
end # MongoMapper
