# encoding: utf-8
class ExportController < ApplicationController
  include ActionController::Live

  def index
    user = User.find_by_username(params[:username])
    if user == current_user
      respond_to do |format|

        format.csv do
          require 'csv'
          response.headers["Content-Type"] ||= 'text/csv'
          response.headers["Content-disposition"] = "attachment; filename=export.csv"
          response.stream.write ["URL","Title","Date Posted", "Yep / Nope"].to_csv
          user.posts.find_each do |post|
            response.stream.write [post.page.url, post.page.title, post.created_at, post.yn.nil? ? nil : post.yn ? "yep" : "nope"].to_csv
          end
        end

        format.html do
          # Use xml so the browser downloads the file immediately
          response.headers["Content-Type"] ||= 'text/xml'
          response.headers["Content-disposition"] = "attachment; filename=export.html"
          response.stream.write(
                                "<!DOCTYPE NETSCAPE-Bookmark-file-1>\n" +
                                "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">\n" +
                                "<TITLE>Bookmarks</TITLE>\n" +
                                "<H1>Bookmarks</H1>\n" +
                                "<DL><p>\n"
                                )
          user.posts.find_each do |post|
            response.stream.write "<DT><A HREF=\"#{post.page.url}\" ADD_DATE=\"#{post.created_at.to_i}\" TAGS=\"#{post.yn.nil? ? "" : post.yn ? "yep" : "nope"}\">#{post.page.title}</A>\n"
            response.stream.write "<DD>#{post.page.description}\n" if post.page.description
          end
          response.stream.write "</DL><p>"
        end

      end
    else
      show_404
    end
  ensure
    response.stream.close
  end

  private

  def set_headers
    response.headers["Content-Transfer-Encoding"] = "binary"
    set_no_cache_headers # needed to work with Cloudflare
  end

end
