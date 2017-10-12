class ArticlesController < ApplicationController

  def index
  end

  def new
    authenticate!
    @default_category_id = params[:cat_id]
    category_array = []
    Category.all.each { |category| category_array << [category.name, category.id] }
    @category = category_array
  end

  def create
    authenticate!
    article = Article.new(post_params)
    article.author_id = current_user.id
    if article.save
      if article.is_published
        redirect_to article_url(article), notice: "Article successfully created and published!"
      else
        redirect_to user_url(current_user), notice: "Article successfully created and saved as a draft!"
      end
    else
      @errors = article.errors.full_messages
      category_array = []
      Category.all.each { |category| category_array << [category.name, category.id] }
      @category = category_array
      render "articles/new"
    end
  end

  def show
    @article = find_and_ensure_article(params[:id])
  end

  def edit
    @article = find_and_ensure_article(params[:id])

    authorize!(@article.author)

    category_array = []
    Category.all.each { |category| category_array << [category.name, category.id] }
    @category = category_array
  end

  def update
    @article = find_and_ensure_article(params[:id])
    @article.update(post_params)
    p "****************"
    p "EDIT!!!!!"
    p "Category ID: #{post_params[:category_id]}"
    p "Publish status: #{post_params[:is_published]}"
    p "****************"
    redirect_to article_url(@article), notice: "Article successfully edited!"
  end

  def destroy
  end

  def find_and_ensure_article(id)
    article = Article.find_by(id: id)
    render :file => "#{Rails.root}/public/404.html", :status => 404 unless article && article.is_published == true
    article
  end

  def post_params
    params.require(:article).permit(:category_id, :title, :body, :is_published)
  end

end
