require 'rails_helper'

RSpec.describe ActAsGroup::Routes, type: :controller do
  describe 'by default' do
    it 'all the routes are exposed' do
      expect(post: '/default_posts/groups').to be_routable
      expect(put: '/default_posts/groups/1').to be_routable
      expect(delete: '/default_posts/groups/1').to be_routable
    end
  end

  describe 'usage of :only' do
    it 'all except the listed parameters are exposed' do
      expect(post: '/only_posts/groups').to be_routable
      expect(put: '/only_posts/groups/1').not_to be_routable
      expect(delete: '/only_posts/groups/1').to be_routable
    end
  end

  describe 'usage of :except' do
    it 'only the listed parameters are exposed' do
      expect(post: '/except_posts/groups').to be_routable
      expect(put: '/except_posts/groups/1').to be_routable
      expect(delete: '/except_posts/groups/1').not_to be_routable
    end
  end
end
