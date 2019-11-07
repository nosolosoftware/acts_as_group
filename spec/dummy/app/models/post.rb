class Post
  include Mongoid::Document
  include ActAsGroup::Callbacks

  field :title
  field :authorized, type: Boolean
  field :draft, type: Boolean, default: false

  def custom_destroy
    destroy if authorized
  end
end
