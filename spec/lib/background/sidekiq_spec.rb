require 'rails_helper'

require 'sidekiq/testing'
RSpec.describe ActAsGroup::Background::Sidekiq do
  before(:all) do
    ActiveJob::Base.queue_adapter = :test

    Rails.application.config.active_job.queue_adapter = :sidekiq

    ActAsGroup.configure do
      background :sidekiq
    end
  end

  let(:group) { ActAsGroup::Group.new({}) }

  describe '#destroy' do
    it 'is defined' do
      expect(group).to respond_to(:destroy)
    end

    it 'enqueues a new job' do
      expect { group.destroy }.to change(
        ActAsGroup::Background::Sidekiq::DelayedModel.jobs, :size
      ).by(1)
    end
  end

  describe '#update' do
    it 'is defined' do
      expect(group).to respond_to(:update)
    end

    it 'enqueues a new job' do
      expect { group.update }.to change(
        ActAsGroup::Background::Sidekiq::DelayedModel.jobs, :size
      ).by(1)
    end
  end
end
