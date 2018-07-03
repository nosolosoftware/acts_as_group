require 'rails_helper'

RSpec.describe ActAsGroup::Controller::Install do
  describe '.act_as_group' do
    context 'when is called without parameters' do
      class self::TestRecord < ApplicationController
        act_as_group
      end

      let(:record) { self.class::TestRecord.new }

      it 'add all the methods' do
        expect(record).to respond_to(:create_group)
        expect(record).to respond_to(:update_group)
        expect(record).to respond_to(:destroy_group)
      end
    end

    context 'when is called specifying the only parameters' do
      class self::TestRecord < ApplicationController
        act_as_group only: %i[create update]
      end

      let(:record) { self.class::TestRecord.new }

      it 'add only the specified methods' do
        expect(record).to respond_to(:create_group)
        expect(record).to respond_to(:update_group)
        expect(record).not_to respond_to(:destroy_group)
      end
    end

    context 'when is called specifying the except parameters' do
      class self::TestRecord < ApplicationController
        act_as_group except: %i[create update]
      end

      let(:record) { self.class::TestRecord.new }

      it 'add all except the specified methods' do
        expect(record).not_to respond_to(:create_group)
        expect(record).not_to respond_to(:update_group)
        expect(record).to respond_to(:destroy_group)
      end
    end
  end
end
