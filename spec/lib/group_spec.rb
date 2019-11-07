require 'rails_helper'

RSpec.describe ActAsGroup::Group do
  describe '#attributes' do
    let(:attributes) { {type: 'type', id: 'id', ids: [1], owner_id: 'owner_id'} }
    let(:group) { ActAsGroup::Group.new(attributes) }

    it 'returns a hash with the attributes' do
      expect(group.attributes).to eq(attributes)
    end
  end

  describe '#valid?' do
    context 'when no type is provided' do
      let(:group) { ActAsGroup::Group.new(id: 'id', ids: [1], owner_id: 'owner_id') }

      it 'returns false' do
        expect(group.valid?).to be_falsey
      end
    end

    context 'when no owner is provided' do
      let(:group) { ActAsGroup::Group.new(id: 'id', type: 'type', ids: [1]) }

      it 'returns false' do
        expect(group.valid?).to be_falsey
      end
    end

    context 'when no ids are provided' do
      let(:group) { ActAsGroup::Group.new(id: 'id', type: 'type', owner_id: 'owner') }

      it 'returns false' do
        expect(group.valid?).to be_falsey
      end
    end

    context 'when all fields are valid' do
      let(:group) { ActAsGroup::Group.new(id: 'id', type: 'type', ids: [1], owner_id: 'owner') }

      it 'returns true' do
        expect(group).to be_truthy
      end
    end
  end

  describe '#eql?' do
    let(:common_id) { 'common_id' }
    let(:different_id) { 'different_id' }
    let(:group) { ActAsGroup::Group.new(id: common_id) }
    let(:other_group_same_id) { ActAsGroup::Group.new(id: common_id) }
    let(:other_group_different_id) { ActAsGroup::Group.new(id: different_id) }

    context 'when id are not equal' do
      it 'returns false' do
        expect(group).not_to eq(other_group_different_id)
      end
    end

    context 'when id are equal' do
      it 'returns true' do
        expect(group).to eq(other_group_same_id)
      end
    end
  end

  describe 'actions', mock_find_user: true do
    let(:documents) do
      posts = []
      4.times do
        posts << Post.create(title: 'authorized', authorized: true)
      end
      posts << Post.create(authorized: false)
      posts
    end
    let(:not_authorized_documents) { documents.reject(&:authorized) }
    let(:authorized_documents) { documents.select(&:authorized) }
    let(:document_type) { documents.first.class.to_s }
    let(:document_ids) { documents.map(&:id).map(&:to_s) }
    let(:owner_id) { 'owner_id' }

    let(:group) do
      ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: owner_id)
    end

    describe '#destroy' do
      context 'when default method is used' do
        before do
          ActAsGroup.configure do
            authorize? { |document, _method| document.authorized }
          end
        end

        context 'when resources are checked', :run_delayed_jobs do
          it 'not authorized resources are sent to failed callback' do
            expect(Post).to receive(:invoke_after_failed_group_delete)
              .with(group, not_authorized_documents.map(&:id))
            group.destroy
          end

          it 'successful callback is not called' do
            expect(Post).not_to receive(:invoke_after_successful_group_delete)
            group.destroy
          end

          it 'authorized resources are removed' do
            group.destroy

            authorized_documents.each do |document|
              expect(Post.where(_id: document.id).exists?).to be_falsey
            end
          end

          it 'not authorized resources are_not removed' do
            group.destroy

            not_authorized_documents.each do |document|
              expect(Post.where(_id: document.id).exists?).to be_truthy
            end
          end
        end
      end

      context 'when a different method is used' do
        before do
          ActAsGroup.configure do
            authorize? { true }
            destroy_resource :custom_destroy
          end
        end

        context 'when resources are checked', :run_delayed_jobs do
          it 'all resources are sent to successful callback' do
            expect(Post).to receive(:invoke_after_successful_group_delete)
              .with(group)
            group.destroy
          end

          it 'failed callback is not called' do
            expect(Post).not_to receive(:invoke_after_failed_group_delete)
            group.destroy
          end

          it 'authorized resources are removed' do
            expect_any_instance_of(ActAsGroup::Group).to receive(:documents).and_return(documents)
            documents.each do |d|
              expect(d).to receive(:custom_destroy).and_call_original
            end
            group.destroy

            authorized_documents.each do |document|
              expect(Post.where(_id: document.id).exists?).to be_falsey
            end
          end

          it 'not authorized resources are_not removed' do
            group.destroy

            not_authorized_documents.each do |document|
              expect(Post.where(_id: document.id).exists?).to be_truthy
            end
          end
        end
      end
    end

    describe '#update' do
      subject(:update_group) do
        group.update(update_params)
      end

      let(:update_params) { {draft: true} }

      context 'when default method is used' do
        before do
          ActAsGroup.configure do
            authorize? { |document, _method| document.authorized }
          end
        end

        context 'when resources are checked', :run_delayed_jobs do
          it 'not authorized resources are sent to failed callback' do
            expect(Post).to receive(:invoke_after_failed_group_update)
              .with(group, not_authorized_documents.map(&:id), update_params)
            update_group
          end

          it 'successful callback is not called' do
            expect(Post).not_to receive(:invoke_after_successful_group_update)
            update_group
          end

          it 'authorized resources are removed' do
            update_group

            authorized_documents.each do |document|
              expect(Post.find(document.id).draft).to eq true
            end
          end

          it 'not authorized resources are_not updated' do
            update_group

            not_authorized_documents.each do |document|
              expect(Post.find(document.id).draft).not_to eq true
            end
          end
        end
      end

      context 'when a different method is used' do
        before do
          ActAsGroup.configure do
            authorize? { true }
          end
        end

        context 'when resources are checked', :run_delayed_jobs do
          it 'all resources are sent to successful callback' do
            expect(Post).to receive(:invoke_after_successful_group_update)
              .with(group, update_params)
            update_group
          end

          it 'failed callback is not called' do
            expect(Post).not_to receive(:invoke_after_failed_group_update)
            update_group
          end

          it 'authorized resources are updated' do
            expect_any_instance_of(ActAsGroup::Group).to receive(:documents).and_return(documents)
            documents.each do |d|
              expect(d).to receive(:update).and_call_original
            end
            update_group

            authorized_documents.each do |document|
              expect(Post.find(document.id).draft).to eq true
            end
          end
        end
      end
    end
  end

  describe 'model_name' do
    let(:documents) do
      Array.new(4, Post.create(title: 'authorized', authorized: true))
    end
    let(:document_type) { documents.first.class.to_s }
    let(:document_ids) { documents.map(&:id).map(&:to_s) }

    context 'when default', :run_delayed_jobs do
      before do
        ActAsGroup.configure do
          authorize? { |document, _method, user| document.authorized && user.present? }
        end
      end

      let(:user) { User.create }
      let(:group) do
        ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: user.id)
      end

      it 'update' do
        expect { group.update(draft: true) }.not_to raise_error
      end

      it 'destroy' do
        expect { group.destroy }.not_to raise_error
      end
    end

    context 'when admin', :run_delayed_jobs do
      before do
        admin_class = Class.new do
          include Mongoid::Document
          store_in collection: 'admins'
        end

        stub_const('Admin', admin_class)

        ActAsGroup.configure do
          authorize? { |document, _method, user| document.authorized && user.is_a?(Admin) }
          model_name 'Admin'
        end
      end

      let(:admin) { Admin.create }
      let(:group) do
        ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: admin.id)
      end

      it 'update' do
        expect { group.update(draft: true) }.not_to raise_error
      end

      it 'destroy' do
        expect { group.destroy }.not_to raise_error
      end
    end
  end
end
