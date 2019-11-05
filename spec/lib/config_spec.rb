require 'rails_helper'

RSpec.describe ActAsGroup::Config do
  describe '.orm' do
    context 'when is not specified' do
      before do
        ActAsGroup.configure {}
      end

      it 'uses cache as default' do
        expect(ActAsGroup.configuration.orm).to eq(:cache)
      end
    end

    context 'when options are passed' do
      let(:time_expiration_group) { 20.minutes }

      before do
        time = time_expiration_group
        ActAsGroup.configure do
          orm :cache, time_expiration_group: time
        end
      end

      it 'adds orm_options' do
        expect(ActAsGroup.configuration).to respond_to(:orm_options)
      end

      it 'adds orm' do
        expect(ActAsGroup.configuration.orm).to eq(:cache)
      end

      it 'install the orm into ActAsGroup::Group' do
        expect(ActAsGroup::Group.ancestors).to include(ActAsGroup::Orm::Cache)
      end

      it 'set the options in the ActAsGroup::Orm::Cache' do
        expect(ActAsGroup::Orm::Cache.time_expiration_group).to eq(time_expiration_group)
      end
    end

    context 'when no options are passed' do
      before do
        ActAsGroup.configure do
          orm :cache
        end
      end

      it 'doesn\'t add orm_options' do
        expect(ActAsGroup.configuration).not_to respond_to(:orm_options)
      end

      it 'adds orm' do
        expect(ActAsGroup.configuration.orm).to eq(:cache)
      end

      it 'installs the orm into ActAsGroup::Group' do
        expect(ActAsGroup::Group.ancestors).to include(ActAsGroup::Orm::Cache)
      end
    end
  end

  describe '.background' do
    context 'when is not specified' do
      before do
        ActAsGroup.configure {}
      end

      it 'uses cache as default' do
        expect(ActAsGroup.configuration.background).to eq(:delayed_job)
      end
    end

    context 'when no options are passed' do
      before do
        ActAsGroup.configure do
          background :sidekiq
        end
      end

      it 'adds background' do
        expect(ActAsGroup.configuration.background).to eq(:sidekiq)
      end

      it 'installs the background into ActAsGroup::Group' do
        expect(ActAsGroup::Group.ancestors).to include(ActAsGroup::Background::Sidekiq)
      end
    end
  end

  describe '.destroy_resource' do
    context 'when is not specified' do
      before do
        ActAsGroup.configure {}
      end

      it 'uses cache as default' do
        expect(ActAsGroup.configuration.destroy_resource).to eq(:destroy)
      end
    end

    context 'when no options are passed' do
      before do
        ActAsGroup.configure do
          destroy_resource :custom_destroy
        end
      end

      it 'adds the method' do
        expect(ActAsGroup.configuration.destroy_resource).to eq(:custom_destroy)
      end
    end
  end

  describe '.update_resource' do
    context 'when is not specified' do
      before do
        ActAsGroup.configure {}
      end

      it 'uses cache as default' do
        expect(ActAsGroup.configuration.update_resource).to eq(:update)
      end
    end

    context 'when no options are passed' do
      before do
        ActAsGroup.configure do
          update_resource :custom_update
        end
      end

      it 'adds the method' do
        expect(ActAsGroup.configuration.update_resource).to eq(:custom_update)
      end
    end
  end

  describe '.model_name' do
    context 'when is not specified' do
      before do
        ActAsGroup.configure {}
      end

      it 'uses user as default' do
        expect(ActAsGroup.configuration.model_name).to eq(:user)
      end
    end

    context 'when is specified' do
      before do
        ActAsGroup.configure do
          model_name :admin
        end
      end

      it 'uses specified value' do
        expect(ActAsGroup.configuration.model_name).to eq(:admin)
      end
    end
  end
end
