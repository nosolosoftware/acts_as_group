module ActAsGroup
  module Background
    module Sidekiq
      extend ActiveSupport::Concern

      included do
        require 'sidekiq/extensions/generic_proxy'

        class DelayedModel
          include ::Sidekiq::Worker

          def perform(yml)
            (target, method_name, args) = YAML.load(yml)
            target.__send__(method_name, *args)
          end
        end

        def sidekiq_delay(options={})
          ::Sidekiq::Extensions::Proxy.new(DelayedModel, self, options)
        end

        alias_method :delay, :sidekiq_delay

        def update_later(*args)
          send(:delay, {}).send(:update_sync_now, *args)
        end

        def destroy_later
          send(:delay, {}).send(:destroy_sync_now)
        end

        alias_method :update, :update_later
        alias_method :destroy, :destroy_later
        alias_method :update_sync_now, :update_sync
        alias_method :destroy_sync_now, :destroy_sync
      end
    end
  end
end
