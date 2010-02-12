module MongoMapper
  module Plugins
    module Associations
      class ManyEmbeddedProxy < EmbeddedCollection
        def serializable_fhash(*args)
          raise 'foo'
        end
        
        def replace(values)
          duts "ManyEmbeddedProxy replace #{values.inspect}"
          @_values = values.map do |v|
            v.respond_to?(:attributes) ? v.attributes : v
          end
          reset
        end

        private
          def find_target
            (@_values || []).map do |v|
              child = klass.load(v)
              assign_references(child)
              child
            end
          end
      end
    end
  end
end
