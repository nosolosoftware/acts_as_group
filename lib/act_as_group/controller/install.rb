module ActAsGroup
  module Controller
    module Install
      extend ActiveSupport::Concern

      class_methods do
        def act_as_group(options={})
          except = Util.parse_methods(options.delete(:except))
          methods = Util.parse_methods(options.delete(:only)) - except
          available_methods = ActionMethods.public_instance_methods

          methods = available_methods - except if methods.blank?

          # https://github.com/ruby/ruby/blob/3c45a7899e239e7ece3c778d9f71e3be85fdfbed/lib/delegate.rb#L39
          include ActionMethods
          available_methods.each do |method|
            undef_method method if methods.present? && !methods.include?(method)
          end

          before_action :find_group, only: Util::FIND_GROUP_METHODS & methods
        end
      end
    end
  end
end

ActionController::API.send(:include, ActAsGroup::Controller::Install)
