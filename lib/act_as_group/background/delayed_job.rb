module ActAsGroup
  module Background
    module DelayedJob
      extend ActiveSupport::Concern

      included do
        def update(*args)
          update_sync(args)
        end

        def destroy
          destroy_sync
        end

        handle_asynchronously :destroy
        handle_asynchronously :update
      end
    end
  end
end
