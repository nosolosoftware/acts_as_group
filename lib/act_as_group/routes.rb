module ActAsGroup
  class Routes
    module Helper
      def act_as_group(options={})
        ActAsGroup::Routes.new(self).generate_routes!(options)
      end
    end

    attr_reader :routes

    def initialize(routes)
      @routes = routes
    end

    def generate_routes!(options)
      process_options(options)

      routes.collection do
        routes.post(:groups, action: :create_group) if @create
        routes.put('groups/:group_id', action: :update_group) if @update
        routes.delete('groups/:group_id', action: :destroy_group) if @destroy
      end
    end

    protected

    def process_options(options)
      @create = @update = @destroy = true

      return unless options.include?(:only) || options.include?(:except)

      if options.include?(:only)
        @create = @update = @destroy = false

        options[:only].each do |verb|
          instance_variable_set("@#{verb}", true)
        end
      else
        options[:except].each do |verb|
          instance_variable_set("@#{verb}", false)
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  ActionDispatch::Routing::Mapper.send :include, ActAsGroup::Routes::Helper
end
