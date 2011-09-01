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

    for post in @posts
      xml.item do
        xml.title "#{post.user.display_name} is #{post.page.domain.verb} \"#{post.page.title}\"" << (post.referrer_post ? " because of #{post.referrer_post.user.display_name}" : '')
        xml.link post.wrapped_url
        xml.guid post.wrapped_url
        xml.description { xml.cdata! render :partial => 'posts/hipchat_message.html.erb', :locals => {:post => post} }
        xml.pubDate post.created_at.to_s(:rfc822)
      end
    end
  end
end
