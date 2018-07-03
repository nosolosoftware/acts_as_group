module ActAsGroup
  module Controller
    module ActionMethods
      def create_group
        group = Group.new(type: permitted_params[:document_type],
                          ids: permitted_params[:document_ids],
                          owner_id: permitted_params[:owner_id])

        if group.valid?
          authorize_group(group, action_name)
          group.save

          render json: {data: group.attributes}, status: 201
        else
          render json: {}, status: 422
        end
      end

      def update_group
        @group.update(update_params)
        render json: {}, status: 202
      end

      def destroy_group
        @group.destroy
        render json: {}, status: 202
      end

      private

      def permitted_params
        params.require(:data).slice(:document_type, :document_ids, :owner_id)
      end

      def update_params
        params.require(:data)
      end

      def authorize_group(group, action_name)
        raise ActAsGroup::NotAuthorizedError unless instance_exec(
          group, action_name, &ActAsGroup.configuration.authorize?
        )
      end

      def find_group
        @group = Group.find(params[:group_id])
        authorize_group(@group, action_name)
      end
    end
  end
end
