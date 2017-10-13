class UsersController < ApplicationController
  def index
  end

  def new
  end

  def create
    user = User.new(post_params)
    if user.save
      session[:user_id] = user.id
      redirect_to categories_url, notice: "Thanks for registering! Enjoy your stay!"
    else
      @errors = user.errors.full_messages
      render "users/new"
    end
  end

  def show
    @user = find_and_ensure_user(params[:id])
  end

  def edit
    authenticate!
    @user = find_and_ensure_user(params[:id])
  end

  def update
    authenticate!
    @user = find_and_ensure_user(params[:id])
    authorize!(@user)
    if params[:commit] == "Save Picture"
      @user.update(profile_pic_url: parse_src(params[:user][:profile_pic_url]))
      render "users/show"
    else
      if @user.update(post_params)
        redirect_to user_url(@user), notice: "User bio successfully edited!"
      else
        @errors = @article.errors.full_messages
        render "users/show"
      end
    end
  end

  private

  def parse_src(string)
    low_index = string.index("//")
    high_index = string.index("png") + 2
    string[low_index..high_index]
  end

  def post_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :bio)
  end

  def find_and_ensure_user(id)
    user = User.find_by(id: id)
    render :file => "#{Rails.root}/public/404.html", :status => 404 unless user
    user
  end

end


