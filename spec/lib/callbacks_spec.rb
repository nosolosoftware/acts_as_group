require 'rails_helper'

RSpec.describe ActAsGroup::Callbacks, :run_delayed_jobs, mock_find_user: true do
  before do
    document_class = Class.new do
      include Mongoid::Document
      include ActAsGroup::Callbacks

      store_in collection: 'documents'

      field :signature, type: String

      after_successful_group_update :hook1, :hook2
      after_failed_group_update :hook3
      after_successful_group_delete :hook4
      after_failed_group_delete :hook5
      after_failed_group_delete :hook6

      def self.hook1(group, attributes); end

      def self.hook2(group, attributes); end

      def self.hook3(group, error_ids, attributes); end

      def self.hook4(group); end

      def self.hook5(group, error_ids); end

      def self.hook6(group, error_ids); end
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
  let(:group) { ActAsGroup::Group.create(type: document_type, ids: document_ids, owner_id: owner_id) }

  describe 'successful callbacks' do
    before do
      ActAsGroup.configure do
        authorize? { true }
      end
    end

    describe '.after_successful_group_update' do
      it 'calls proper hooks' do
        %i[hook1 hook2].each do |hook|
          expect(DocumentClass).to receive(hook).with(group, update_params)
        end

        %i[hook3 hook4 hook5 hook6].each do |hook|
          expect(DocumentClass).not_to receive(hook)
        end
        group.update(update_params)
      end
    end

    describe '.after_successful_group_delete' do
      it 'calls proper hooks' do
        expect(DocumentClass).to receive(:hook4).with(group)
        %i[hook1 hook2 hook3 hook5 hook6].each do |hook|
          expect(DocumentClass).not_to receive(hook)
        end
        group.destroy
      end
    end
  end

  describe 'failed callbacks' do
    before do
      ActAsGroup.configure do
        authorize? { false }
      end
    end

    describe '.after_failed_group_update' do
      it 'calls proper hooks' do
        expect(DocumentClass).to receive(:hook3).with(group, documents.map(&:id), update_params)
        %i[hook1 hook2 hook4 hook5 hook6].each do |hook|
          expect(DocumentClass).not_to receive(hook)
        end
        group.update(update_params)
      end
    end

    describe '.after_failed_group_delete' do
      it 'calls proper hooks' do
        %i[hook5 hook6].each do |hook|
          expect(DocumentClass).to receive(hook).with(group, documents.map(&:id))
        end

        %i[hook1 hook2 hook3 hook4].each do |hook|
          expect(DocumentClass).not_to receive(hook)
        end
        group.destroy
      end
    end
  end
end
