require 'rails_helper'

RSpec.describe ActAsGroup::Controller::Util, type: :request do
  before(:all) do
    ActAsGroup.configure do
      authorize? do |_, _, user|
        user
      end
    end
  end

  let(:authorized_user) { true }
  let(:unauthorized_user) { false }
  let(:group) { nil }
  let(:action_name) { :create }

  describe '.parse_methods' do
    context 'when methods do not have groups' do
      let(:methods) { %w[method1 method2] }

      it 'add the suffix _group' do
        expect(described_class.parse_methods(methods)).to eq(
          methods.map { |method| "#{method}_group".to_sym }
        )
      end
    end

    context 'when methods have groups' do
      let(:methods) { %w[method1_group method2_group] }

      it 'add the suffix _group' do
        expect(described_class.parse_methods(methods)).to eq(methods.map(&:to_sym))
      end
    end
  end
end
