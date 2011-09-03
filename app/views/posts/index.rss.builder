display_name = @user.nil? ? 'Everybody' : @user.display_name

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{display_name}'s Reading #{params[:type] == 'list' ? 'List' : 'Posts'}"
    xml.description "All of the great stuff that #{display_name} #{params[:type] == 'list' ? "and the people it's following are" : 'is'} reading!"
    xml.link request.url[0...-4] # lob off .rss
    xml.atom :link, nil, {
      :href => request.url,
      :rel => 'self', :type => 'application/rss+xml'
    }
    # validate that this is a real user
    # TODO this should really happen in the controller
    if User.find_by_token(params[:t])
      for post in @posts
        xml.item do
          xml.title "#{post.user.display_name} is #{!post.page.domain.nil? ? post.page.domain.verb : 'reading'} \"#{post.page.title}\"" << (post.referrer_post ? " because of #{post.referrer_post.user.display_name}" : '')
          xml.link post.wrapped_url params[:t]
          xml.guid post.wrapped_url
          xml.description { xml.cdata! render :partial => 'posts/hipchat_message.html.erb', :locals => {:post => post, :token => params[:t]} }
          xml.pubDate post.created_at.to_s(:rfc822)
        end
      end
    else
      xml.item do
        xml.title "RSS feeds are for registered Reading users only"
        xml.link "http://reading.am"
        xml.guid "http://reading.am"
        xml.description "RSS feeds are for registered Reading users only. Please log in or register and grab a new RSS link."
      end
    end
  end
end
