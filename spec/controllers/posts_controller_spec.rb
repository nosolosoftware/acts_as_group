require 'rails_helper'

RSpec.describe PostsController do
  let(:unauthorized_user) { 'unauthorized' }
  let(:authorized_user) { 'authorized' }

  before do
    auth = authorized_user
    ActAsGroup.configure do
      authorize? do |_, _|
        current_user == auth
      end
    end
  end

  describe '#create_group' do
    context 'when there are some errors' do
      let(:invalid_data) { {owner_id: authorized_user, type: nil} }

      before do
        post :create_group, params: {data: invalid_data}
      end

      it 'returns 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when is not authorized' do
      let(:invalid_data) { {owner_id: unauthorized_user, document_type: 'T', document_ids: [1]} }

      before do
        sign_in unauthorized_user
        post :create_group, params: {data: invalid_data}
      end

      it 'returns 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when all is valid' do
      let(:valid_data) { {owner_id: authorized_user, document_type: 'T', document_ids: [1]} }

      before do
        sign_in authorized_user
      end

      it 'creates a new group' do
        expect_any_instance_of(ActAsGroup::Group).to receive(:save)
        post :create_group, params: {data: valid_data}
      end

      it 'returns 201' do
        post :create_group, params: {data: valid_data}
        expect(response).to have_http_status(201)
      end
    end

    describe '#update_group' do
      let(:attributes) { {type: 'type', ids: [1], owner_id: unauthorized_user} }

      before do
        @group = ActAsGroup::Group.create(attributes)
      end

      context 'when is not authorized' do
        before do
          sign_in unauthorized_user
          put :update_group, params: {group_id: @group.id, data: attributes}
        end

        it 'returns 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when all is valid' do
        let(:valid_data) { {owner_id: authorized_user, document_type: 'T', document_ids: [1]} }

        before do
          sign_in authorized_user
        end

        it 'returns 202' do
          put :update_group, params: {group_id: @group.id, data: valid_data}
          expect(response).to have_http_status(202)
        end
      end
    end

    describe '#destroy_group' do
      let(:attributes) { {type: 'type', ids: [1], owner_id: unauthorized_user} }

      before do
        @group = ActAsGroup::Group.create(attributes)
      end

      context 'when is not authorized' do
        before do
          sign_in unauthorized_user
        end

        it 'returns 403' do
          delete :destroy_group, params: {group_id: @group.id}
          expect(response).to have_http_status(403)
        end
      end

      context 'when all is valid' do
        before do
          sign_in authorized_user
        end

        it 'returns 202' do
          delete :destroy_group, params: {group_id: @group.id}
          expect(response).to have_http_status(202)
        end
      end
    end
  end
end
