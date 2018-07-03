require 'rails_helper'

RSpec.describe ActAsGroup::Orm::Cache do
  before(:all) do
    ActAsGroup.configure do
      orm :cache
    end
  end

  let(:valid_attributes) { {owner_id: 'owner_id', ids: [1], type: 't'} }

  describe '.find' do
    context 'when resource doesn\'t exist' do
      let(:not_existing_id) { 'not_existing' }

      it 'raises an exception' do
        expect { ActAsGroup::Group.find(not_existing_id) }.to raise_error(ArgumentError)
      end
    end

    context 'when resource exists' do
      let(:group) { ActAsGroup::Group.create(valid_attributes) }
      let(:existing_id) { group.id }

      it 'return the very document' do
        expect(ActAsGroup::Group.find(existing_id)).to eq(group)
      end
    end
  end

  describe '.create' do
    context 'when is called' do
      before do
        @group = ActAsGroup::Group.create(valid_attributes)
      end

      it 'persits the document' do
        expect(ActAsGroup::Group.find(@group.id)).to eq(@group)
      end
    end
  end

  describe '#save' do
    context 'when resource was not previously saved' do
      before do
        @group = ActAsGroup::Group.new(valid_attributes)
      end

      it 'persists the group' do
        expect { ActAsGroup::Group.find(@group.id) }.to raise_error(ArgumentError)

        @group.save

        expect(ActAsGroup::Group.find(@group.id)).to eq(@group)
      end
    end
  end
end
