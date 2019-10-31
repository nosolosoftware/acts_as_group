class Post
  include Mongoid::Document
  include ActAsGroup::Callbacks

  field :title
  field :authorized, type: Boolean

  def custom_destroy
    destroy if authorized
  end
end
