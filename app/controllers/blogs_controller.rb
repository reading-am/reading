class BlogsController < ApplicationController
  before_filter :authenticate_user!

  def show
    if !current_user.access?(:tumblr_templates) then not_found end

    @user = User.find_by_username(params[:username])
    if !@user then not_found end

    @page_title = @user.name.blank? ? @user.username : "#{@user.name} (#{@user.username})"
    @posts = @user.posts.order("created_at DESC").paginate(:page => params[:page]).map do |p|
      data = {'type' => p.page.medium.to_s, 'title' => p.page.title, 'body' => p.page.excerpt, 'timestamp' => p.created_at.to_i}
      case p.page.medium
      when :text
        data['type'] = 'link'
        data['link-url'] = p.page.url
        data['link-text'] = p.page.title
        data['link-description'] = p.page.excerpt
      when :audio
        data['player'] = p.page.embed
      when :video
        data['player'] = [500,400,250].map{|w| {'width'=>w,'embed_code'=>p.page.embed}}
      when :image
        data['type'] = 'photo'
        data['photos'] = [{'alt_sizes' => [500, 400, 250, 100].map{|w| {'width'=>w,'url'=>p.page.image}}}]
      end
      data
    end

    if @user.blogs.first && @user.blogs.first.template
      template = Tuml::Template.new @user.blogs.first.template
    else
      template = Tuml::Template.new Blog.find(1).template
    end

    page = Tuml::IndexPage.new('title' => @page_title, 'description' => @user.bio, 'posts' => @posts)

    respond_to do |format|
      format.html { render :text => template.render(page) }
    end
  end

  def update
    @blog = Blog.find(params[:id])
    if @blog.user != current_user then not_found end

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        format.html { redirect_to "/settings/info", notice: 'Template was successfully updated.' }
      else
        format.html { redirect_to "/settings/info" }
      end
    end
  end

end
