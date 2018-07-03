class ApplicationController < ActionController::API
  rescue_from ActAsGroup::NotAuthorizedError, with: :render_403

  def current_user; end
  def render_403
    render json: {}, status: 403
  end
end
