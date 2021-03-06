class BlogsController < ApplicationController
  before_action :set_user

  layout 'blog'

  def index
    @posts = SearchEngine.search(
      @user,
      params[:query],
      user_signed_in?,
      params[:page],
      search_options)
  end

  def show
    @post = @user.posts.friendly.find(params[:id])
  end

  def about
    @about = @user.about
  end

  private

  def set_user
    @user  = User.find_by_subdomain(request.subdomain)
    raise "Not Found" if @user.blank?
  end

  def search_options
    opts = []

    if params[:kind].present?
      opts.push(:kind)
    end

    params.permit(opts)
  end
end