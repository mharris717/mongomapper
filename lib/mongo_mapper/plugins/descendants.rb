module MongoMapper
  module Plugins
    module Descendants
      extend ActiveSupport::Concern
      module ClassMethods
        def inherited(descendant)
          (@descendants ||= []) << descendant
          super
        end

        def descendants
          @descendants
        end
      end
    end
  end
end