module ActAsGroup
  class Group
    attr_reader :ids, :type, :owner_id, :id

    def initialize(attributes)
      @id = attributes[:id] || SecureRandom.hex(14)
      @ids = attributes[:ids]&.map!(&:to_s)
      @type = attributes[:type]
      @owner_id = attributes[:owner_id].to_s
    end

    # Devuelve un hash con los atributos de esta clase
    def attributes
      {id: id, ids: ids, type: type, owner_id: owner_id}
    end

    def valid?
      !(type.blank? || owner_id.blank? || ids.blank? || id.blank?)
    end

    def eql?(other)
      self == other
    end

    def ==(other)
      id == other.id
    end

    protected

    # Devuelve la clase de los documentos del grupo
    def klass
      type.to_s.classify.constantize
    end

    # Invoca el callback si la clase los implementa
    def invoke_callback(callback, *args)
      klass.send(callback, self, *args) if klass.ancestors.include? ActAsGroup::Callbacks
    end

    def destroy_sync
      ids_not_removed = []

      # Destruimos el grupo, lo que quiere decir que borramos todos los elementos que
      # pertenencen a él
      documents.each do |document|
        if ActAsGroup.configuration.authorize?.call(
          document,
          :destroy,
          ActAsGroup.configuration.model_name.to_s.camelize.constantize.find(@owner_id)
        )
          destroy!(document)
        else
          ids_not_removed << document.id
        end
      end

      if ids_not_removed.empty?
        invoke_callback(:invoke_after_successful_group_delete)
      else
        invoke_callback(:invoke_after_failed_group_delete, ids_not_removed)
      end
    end

    def update_sync(attributes)
      ids_not_updated = []

      # Modificamos el grupo, lo que quiere decir que modificamos todos los elementos que
      # pertenencen a él
      documents.each do |document|
        if ActAsGroup.configuration.authorize?.call(
          document,
          :update,
          ActAsGroup.configuration.model_name.to_s.camelize.constantize.find(@owner_id)
        )
          update!(document, attributes)
        else
          ids_not_updated << document.id
        end
      end

      if ids_not_updated.empty?
        invoke_callback(:invoke_after_successful_group_update, attributes)
      else
        invoke_callback(:invoke_after_failed_group_update, ids_not_updated, attributes)
      end
    end

    # Devuelve un criteria con los documentos agrupados
    def documents
      if defined?(Mongoid) && klass.ancestors.include?(Mongoid::Document)
        klass.where(:_id.in => ids)
      else
        klass.where(id: ids)
      end
    end

    # Update this very resource
    def update!(document, attributes)
      document.send(ActAsGroup.configuration.update_resource.to_sym, attributes)
    end

    # Remove this very resource
    def destroy!(document)
      document.send(ActAsGroup.configuration.destroy_resource.to_sym)
    end
  end
end
