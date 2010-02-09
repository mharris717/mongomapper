module MongoMapper
  module Plugins
    module Clone
      extend ActiveSupport::Concern
      module InstanceMethods
        def clone
          clone_attributes = self.attributes
          clone_attributes.delete("_id")
          self.class.new(clone_attributes)
        end
      end
    end
  end
end