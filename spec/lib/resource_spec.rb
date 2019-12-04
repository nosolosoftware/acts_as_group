require 'rails_helper'

RSpec.describe ActAsGroup::Resource, :run_delayed_jobs, mock_find_user: true do
  before do
    document_class = Class.new do
      include Mongoid::Document
      include ActAsGroup::Resource

      store_in collection: 'documents'

      field :signature, type: String

      group_update :test_update
      group_destroy :test_destroy

      def test_update(attributes); end

      def test_destroy; end
    end

    stub_const('DocumentClass', document_class)
  end

  let(:documents) do
    Array.new(3) { DocumentClass.create }
  end
  let(:document_type) { DocumentClass.to_s }
  let(:document_ids) { documents.map(&:id).map(&:to_s) }
  let(:owner_id) { 'owner_id' }
  let(:update_params) { {signature: 'Group signature'} }
  let(:group) do
    ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: owner_id)
  end

  describe 'custom methods' do
    before do
      ActAsGroup.configure do
        authorize? { true }
      end
    end

    it 'calls defined update method' do
      expect_any_instance_of(ActAsGroup::Group).to receive(:documents).and_return(documents)
      documents.each do |document|
        expect(document).to receive(:test_update).with(update_params).and_call_original
        expect(document).not_to receive(:update)
      end
      group.update(update_params)
    end

    it 'calls defined destroy method' do
      expect_any_instance_of(ActAsGroup::Group).to receive(:documents).and_return(documents)
      documents.each do |document|
        expect(document).to receive(:test_destroy).and_call_original
        expect(document).not_to receive(:destroy)
      end
      group.destroy
    end
  end
end
