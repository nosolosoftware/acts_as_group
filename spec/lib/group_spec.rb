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

  describe '#destroy', mock_find_user: true do
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

    let(:group) { ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: owner_id) }

    context 'when default method is used' do
      before do
        ActAsGroup.configure do
          authorize? { |document, _method| document.authorized }
        end
      end

      it 'is called in each one of the ids', :run_delayed_jobs do
        group.destroy

        authorized_documents.each do |document|
          expect(Post.where(_id: document.id).exists?).to be_falsey
        end
      end

      it 'not authorized resources are sent to failed callback', :run_delayed_jobs do
        expect(Post).to receive(:invoke_after_failed_group_delete)
          .with(group, not_authorized_documents.map(&:id))
        group.destroy
      end

      context 'when resources are checked' do
        it 'authorized resources are removed', :run_delayed_jobs do
          group.destroy

          authorized_documents.each do |document|
            expect(Post.where(_id: document.id).exists?).to be_falsey
          end
        end

        it 'not authorized resources are_not removed', :run_delayed_jobs do
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

      it 'not authorized resources are sent to failed callback', :run_delayed_jobs do
        expect(Post).not_to receive(:invoke_after_failed_group_delete)
        group.destroy
      end

      context 'when resources are checked' do
        it 'authorized resources are removed', :run_delayed_jobs do
          expect_any_instance_of(ActAsGroup::Group).to receive(:documents).and_return(documents)
          documents.each do |d|
            expect(d).to receive(:custom_destroy).and_call_original
          end
          group.destroy

          authorized_documents.each do |document|
            expect(Post.where(_id: document.id).exists?).to be_falsey
          end
        end

        it 'not authorized resources are_not removed', :run_delayed_jobs do
          group.destroy

          not_authorized_documents.each do |document|
            expect(Post.where(_id: document.id).exists?).to be_truthy
          end
        end
      end
    end
  end

  describe '#update' do
  end
end
