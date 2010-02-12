module MongoMapper
  module EmbeddedDocument
    extend Support::DescendantAppends
    extend ActiveSupport::Concern
    included do
      extend  Plugins

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
    include Document

    module ClassMethods
      def embeddable?
        duts "ED embeddable?"
        true
      end

      def embedded_in(owner_name)
        define_method(owner_name) { _parent_document }
      end
    end

    module InstanceMethods
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
