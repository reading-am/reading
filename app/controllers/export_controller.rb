# encoding: utf-8
class ExportController < ApplicationController
  include ActionController::Live
  extend ActiveSupport::Concern
  before_action :authenticate_user!, :set_headers

  def posts
    user = current_user
    respond_to do |format|
      format.csv do
        require 'csv'
        columns = ['URL', 'Title', 'Date Posted', 'Yep / Nope']
        response.stream.write columns.to_csv
        user.posts.find_each do |post|
          response.stream.write [post.page.url, post.page.title, post.created_at.to_time.iso8601, post.yn.nil? ? nil : post.yn ? 'yep' : 'nope'].to_csv
          sleep 0.0001 # Response will hang otherwise. See: https://gist.github.com/njakobsen/6257887
        end
      end

      format.html do
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
          sleep 0.0001 # Response will hang otherwise. See: https://gist.github.com/njakobsen/6257887
        end
        response.stream.write "</DL><p>"
      end

      format.json do
        response.stream.write '['
        first = true
        user.posts.find_each do |post|
          response.stream.write "#{first ? '' : ','}\n"
          first = false
          response.stream.write JSON.pretty_generate({ url: post.page.url,
                                                       title: post.page.title,
                                                       description: post.page.description,
                                                       yep_nope: post.yn.nil? ? "" : post.yn ? "yep" : "nope",
                                                       date: post.created_at.to_time.iso8601
                                                     })
          sleep 0.0001 # Response will hang otherwise. See: https://gist.github.com/njakobsen/6257887
        end
        response.stream.write "\n]"
      end
    end
rescue IOError
  # Client Disconnected
  ensure
    response.stream.close
  end

  private

  def set_headers
    # Seems to be the best way to get all browsers to download HTML with the right extension
    response.headers['Content-Type'] ||= 'application/force-download'
    response.headers['Content-Transfer-Encoding'] = 'binary'
    response.headers['Content-disposition'] = "attachment; filename=reading-posts-from-#{Time.now.strftime("%I-%M%p-%m-%d-%Y")}.#{request.params[:format]}"
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate, pre-check=0, post-check=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end
end
