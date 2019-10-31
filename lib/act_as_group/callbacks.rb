module ActAsGroup
  module Callbacks
    extend ActiveSupport::Concern

    class_methods do
      GROUP_CALLBACKS = %i[
        after_successful_group_update after_successful_group_delete
        after_failed_group_update after_failed_group_delete
      ].freeze

      GROUP_CALLBACKS.each do |callback|
        define_method callback do |*methods|
          group_callback_methods[callback].concat(methods)
        end

        define_method "invoke_#{callback}" do |*args|
          group_callback_methods[callback].each do |method|
            send(method, *args)
          end
        end
      end

      private

      def group_callback_methods
        @group_callback_methods ||= Hash[GROUP_CALLBACKS.map { |c| [c, []] }]
      end
    end
  end
end
