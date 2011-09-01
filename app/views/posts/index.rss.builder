xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "#{@user.display_name}'s Reading List"
    xml.description "All of the great stuff that #{@user.display_name} is reading!"
    xml.link request.url[0...-4] # lob off .rss

    for post in @posts
      xml.item do
        xml.title post.page.title
        xml.link post.page.wrapped_url
        xml.description post.page.title
        xml.pubDate post.created_at.to_s(:rfc822)
      end
    end
  end
end
