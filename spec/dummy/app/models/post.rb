class Post
  include Mongoid::Document

  field :title
  field :authorized, type: Boolean

  def custom_destroy
    destroy if authorized
  end
end
