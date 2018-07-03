module ActAsGroup
  module Orm
    module Cache
      extend ActiveSupport::Concern

      # Tiempo de expiracion que se almacena en al cache una seleccion de ids
      def self.time_expiration_group=(value)
        @time_expiration_group = value
      end

      def self.time_expiration_group
        @time_expiration_group ||= 50.minutes.freeze
      end

      class_methods do
        def find(id)
          raise ArgumentError unless Rails.cache.exist?(id)

          attributes = Rails.cache.fetch(id)
          new(attributes)
        end

        def create(attributes)
          group = new(attributes)
          group.save
          group
        end
      end

      included do
        def save
          Rails.cache.write(id, attributes,
                            expires_in: ActAsGroup::Orm::Cache.time_expiration_group)
        end
      end
    end
  end
end
