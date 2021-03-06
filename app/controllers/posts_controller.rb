class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, except: [:index, :new, :create]
  before_action :decrypt_secure_post, only: [:show, :edit]

  # GET /posts
  # GET /posts.json
  def index
    @posts = SearchEngine.search(
      current_user,
      params[:query],
      user_signed_in?,
      params[:page],
      extract_options!
    )
  end

  # GET /posts/1

  # GET /posts/1.json
  def show
    load_comments if @post.default?
  end

  # GET /posts/new
  def new
    @post = current_user.posts.new(kind: params[:kind])
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = PostBuilder.build(current_user, create_post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post = PostBuilder.build(current_user, update_post_params, @post)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def publish
    authorize @post
    @post.publish!
    redirect_to @post
  end

  def unpublish
    authorize @post
    @post.unpublish!
    redirect_to @post
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = current_user.posts.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # :content is required for secret posts
  def create_post_params
    params.require(:post).permit(:title, :kind, :body, :content)
  end

  def update_post_params
    params.require(:post).permit(:title, :kind, :body, :content)
  end

  def decrypt_secure_post
    if @post.secure?
      @post = SecurePost.new(current_user, @post).decrypt
    end
  end

  def extract_options!
    if params.has_key? :kind
      params.permit(:kind)
    else
      {}
    end
  end

  def load_comments
    @comments = @post.comments.order('id desc')
  end
end
