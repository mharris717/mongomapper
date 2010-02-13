module MongoMapper
  module Plugins
    module Validations
      extend ActiveSupport::Concern
      included do
        include ::ActiveModel::Validations
        extend FixValidationKeyNames
        extend LifecycleValidationMethods
      end
      
      module DocumentMacros
        def validates_uniqueness_of(attrs, ops={})
          # add_validations(args, MongoMapper::Plugins::Validations::ValidatesUniquenessOf)
          validates_with ValidatesUniquenessOf, {:attributes => attrs}.merge(ops)
        end
        
        
      end
      
      module FixValidationKeyNames
        def validates_inclusion_of(*args,&b)
          if args.last.kind_of?(Hash)
            args.last[:in] ||= args.last[:within]
          end
          super(*args,&b)
        end
        def validates_exclusion_of(*args,&b)
          if args.last.kind_of?(Hash)
            args.last[:in] ||= args.last[:within]
          end
          super(*args,&b)
        end
      end
      
      module LifecycleValidationMethods
        def validate_on_create(name)
          validate(name, :on => :create)
        end
        def validate_on_update(name)
          validate(name, :on => :update)
        end
      end

      class ValidatesUniquenessOf < ActiveModel::EachValidator
        attr_accessor :scope, :allow_blank, :allow_nil, :attributes, :case_sensitive
        def case_sensitive
          @case_sensitive.nil? ? true : @case_sensitive
        end
        
        def initialize(ops)
          ops.each { |k,v| send("#{k}=",v) }
        end
        
        def validate(record)
          [attributes].flatten.each do |attribute|
            record.errors.add(*message(record,attribute)) unless valid?(record,attribute)
          end
        end
      
        def valid?(instance,attribute)
          value = instance[attribute]
          return true if allow_blank && value.blank?
          return true if allow_nil && value.nil?
          base_conditions = case_sensitive ? {attribute => value} : {}
          doc = instance.class.first(base_conditions.merge(scope_conditions(instance)).merge(where_conditions(instance,attribute)))
          doc.nil? || instance._id == doc._id
        end
      
        def message(instance,attribute)
          [attribute,"has already been taken"]
        end
      
        def scope_conditions(instance)
          return {} unless scope
          Array(scope).inject({}) do |conditions, key|
            conditions.merge(key => instance[key])
          end
        end
      
        def where_conditions(instance, attribute)
          conditions = {}
          conditions[attribute] = /#{instance[attribute].to_s}/i unless case_sensitive
          conditions
        end
      end
    end
  end
end