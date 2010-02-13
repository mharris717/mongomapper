module MongoMapper
  module Plugins
    module Callbacks
      extend ActiveSupport::Concern
      included do
        extend ActiveModel::Callbacks

        # Define all the callbacks that are accepted by the document.
        define_model_callbacks \
        :create,
        :destroy,
        :save,
        :update,
        :terminator => false
        
        define_callbacks :validation, :terminator => "result == false", :scope => [:kind, :name]

        extend ValidationCallbacks

        [:create_or_update, :valid?, :create, :update, :destroy].each do |method|
          alias_method_chain method, :callbacks
        end
      end
        
      module ValidationCallbacks
        def before_validation(*args, &block)
          options = args.extract_options!
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
          set_callback(:validation, :before, *(args << options), &block)
        end

        def after_validation(*args, &block)
          options = args.extract_options!
          options[:prepend] = true
          options[:if] = Array(options[:if])
          options[:if] << "!halted && value != false"
          options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
          set_callback(:validation, :after, *(args << options), &block)
        end
      
        def before_validation_on_what(what, *args, &block)
          options = args.extract_options!
          options[:on] = what
          before_validation(*(args << options), &block)
        end
        
        def before_validation_on_create(*args, &block); before_validation_on_what(:create, *args, &block); end
        def before_validation_on_update(*args, &block); before_validation_on_what(:update, *args, &block); end
      end

      def create_or_update_with_callbacks(*args) #:nodoc:
        _run_save_callbacks do
          create_or_update_without_callbacks(*args)
        end
      end
      private :create_or_update_with_callbacks

      def create_with_callbacks(*args) #:nodoc:
        _run_create_callbacks do
          create_without_callbacks(*args)
        end
      end
      private :create_with_callbacks

      def update_with_callbacks(*args) #:nodoc:
        _run_update_callbacks do
          update_without_callbacks(*args)
        end
      end
      private :update_with_callbacks

      def valid_with_callbacks? #:nodoc:
        @_on_validate = new_record? ? :create : :update
        _run_validation_callbacks do
          valid_without_callbacks?
        end
      end

      def destroy_with_callbacks #:nodoc:
        _run_destroy_callbacks do
          destroy_without_callbacks
        end
      end
    end
  end
end