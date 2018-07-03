module ActAsGroup
  module Controller
    class Util
      FIND_GROUP_METHODS = %i[update_group destroy_group].freeze

      class << self
        def parse_methods(methods)
          Array(methods).map do |method|
            method = "#{method}_group" unless method.to_s.end_with?('_group')
            method.to_sym
          end
        end
      end
    end
  end
end
