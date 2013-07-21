display_name = @user.nil? ? 'everybody' : @user.display_name
# validate that this is a real user. TODO this should really happen in the controller
token = (!params[:t].blank? && User.find_by_token(params[:t])) ? params[:t] : false

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{display_name}'s Reading #{params[:type] == 'list' ? 'List' : 'Posts'}".titleize
    xml.description "All of the great #{medium_to_object params[:medium]} that #{display_name} #{params[:type] == 'list' ? "and the people it's following are" : 'is'} #{medium_to_verb params[:medium]}!"
    xml.link request.url[0...-4] # lob off .rss
    xml.atom :link, nil, {
      :href => request.url,
      :rel => 'self', :type => 'application/rss+xml'
    }

    @posts.each do |post|
      xml.item do
        xml.title "#{post.user.display_name} is #{post.page.verb} \"#{post.page.title}\"" + (post.referrer_post ? " because of #{post.referrer_post.user.display_name}" : '')
        xml.link post.wrapped_url token
        xml.guid post.wrapped_url token
        xml.description { xml.cdata! render :partial => 'posts/rss.html.erb', :locals => {:post => post, :token => token} }
        xml.pubDate post.created_at.to_s(:rfc822)
      end
    end
  end
end
