module ActAsGroup
  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config
  end

  class Config
    class Builder
      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
        setup_orm_adapter
        setup_background_adapter
      end

      def build
        @config
      end

      def setup_background_adapter
        ActAsGroup::Group.send(:include,
                               "act_as_group/background/#{@config.background}".classify.constantize)
      rescue NameError => error
        raise error, "Background adapter not found (#{@config.background})"
      end

      def setup_orm_adapter
        orm = "act_as_group/orm/#{@config.orm}".classify.constantize
        ActAsGroup::Group.send(:include, orm)

        return unless @config.respond_to?(:orm_options)

        @config.orm_options.each do |option, value|
          orm.send("#{option}=", value)
        end
      rescue NameError => error
        raise error, "ORM adapter not found (#{@config.orm})"
      end
    end

    module Option
      # Defines configuration option
      #
      # When you call option, it defines two methods. One method will take place
      # in the +Config+ class and the other method will take place in the
      # +Builder+ class.
      #
      # The +name+ parameter will set both builder method and config attribute.
      # If the +:as+ option is defined, the builder method will be the specified
      # option while the config attribute will be the +name+ parameter.
      #
      # ==== Options
      #
      # * [:+as+] Set the builder method that goes inside +configure+ block
      # * [+:default+] The default value in case no option was set
      #
      # ==== Examples
      #
      #    option :name
      #    option :name, as: :set_name
      #    option :name, default: 'My Name'
      #
      def option(name, options={})
        attribute = options[:as] || name
        name_variable = attribute.to_s.tr('?', '').to_sym

        that = self
        Builder.instance_eval do
          remove_method name if method_defined?(name)

          define_method name do |*args, &block|
            @config.instance_eval do
              if self.class.method_defined?(:orm_options)
                self.class.send(:remove_method, :orm_options)
              end
            end

            if args.size > 1 && args[1].is_a?(Hash)
              @config.instance_variable_set(:"@#{name_variable}_options", args[1])

              that.define_method "#{name}_options" do
                instance_variable_set(:"@#{name_variable}_options", args[1])
              end
            end
            value = block ? block : args.first

            @config.instance_variable_set(:"@#{name_variable}", value)
          end
        end

        define_method attribute do |*_args|
          if instance_variable_defined?(:"@#{name_variable}")
            instance_variable_get(:"@#{name_variable}")
          else
            options[:default]
          end
        end

        public attribute
      end
    end

    extend Option

    option :orm, default: :cache

    option :background, default: :delayed_job

    option :destroy_resource, default: :destroy

    option :update_resource, default: :update

    option :process_errors,
           default: (lambda do |_resource, _action|
           end)

    option :authorize?,
           default: (lambda do |_resource, _action|
             true
           end)
  end
end
