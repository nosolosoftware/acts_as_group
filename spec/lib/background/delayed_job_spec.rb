require 'rails_helper'

RSpec.describe ActAsGroup::Background::DelayedJob do
  before(:each) do
    Rails.application.config.active_job.queue_adapter = :delayed_job
    ActiveJob::Base.queue_adapter = :delayed_job
    Delayed::Worker.delay_jobs = true

    ActAsGroup.configure do
      background :delayed_job
    end
  end

  let(:group) { ActAsGroup::Group.new({}) }

  describe '#destroy' do
    it 'is defined' do
      expect(group).to respond_to(:destroy)
    end

    it 'enqueues a new job' do
      expect { group.destroy }.to change(Delayed::Job, :count).by(1)
    end
  end

  describe '#update' do
    it 'is defined' do
      expect(group).to respond_to(:update)
    end

    it 'enqueues a new job' do
      expect { group.update }.to change(Delayed::Job, :count).by(1)
    end
  end
end
