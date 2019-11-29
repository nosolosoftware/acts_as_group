module ActAsGroup
  module Resource
    extend ActiveSupport::Concern

    class_methods do
      define_method 'group_update' do |method|
        @group_update_method = method
      end

      define_method 'group_destroy' do |method|
        @group_destroy_method = method
      end

      def group_update_method
        @group_update_method
      end

      def group_destroy_method
        @group_destroy_method
      end
    end
  end
end
