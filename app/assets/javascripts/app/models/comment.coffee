define [
  "jquery"
  "backbone"
  "app/init"
  "app/constants"
  "libs/base58"
  "libs/twitter-text"
], ($, Backbone, App, Constants, Base58, TwitterText) ->

  class Comment extends Backbone.Model
    type: "Comment"
    validate: (attr) ->
      if !attr.body || (!attr.page and !attr.page_id)
        return Constants.errors.general

    short_url: ->
      "#{Constants.short_domain}/c/#{Base58.encode(@id)}"

    mentions: ->
      TwitterText.extractMentions @get("body")

    emails: ->
      @get("body").match(Constants.regexes.email)

    hashtags: ->
      TwitterText.extractHashtags @get("body")

    urls: ->
      TwitterText.extractUrls @get("body")

    is_a_show: ->
      m = @mentions()
      return (m.length > 0 and @get("body").replace(/\s|,/g,"").length is "@#{m.join("@")}".length)

    ## This method is mirrored in comment.rb
    body_html: ->
      html = @get "body"
      # nl2br
      html = html.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1<br>$2")
      # wrap code
      html = html.replace /`((?:[^`]+|\\.)*)`/g, '<pre><code>$1</code></pre>'
      # italicize quotes
      html = html.replace(/"(.*)"/, '<i>"$1"</i>')
      # link emails
      html = html.replace Constants.regexes.email,'<a href="mailto:$1" class="r_email">$1</a>'
      # link urls and @mentions
      html = TwitterText.autoLink html,
        urlClass:       "r_url",
        usernameClass:  "r_mention",
        hashtagClass:   "r_tag",
        usernameUrlBase:"//#{Constants.domain}/",
        listUrlBase:    "//#{Constants.domain}/",
        hashtagUrlBase: "//#{Constants.domain}/search?q="
      # embed images
      $html = $("<div>#{html}</div>")
      $html.find("a[href*=\\.#{["jpg","jpeg","png","gif"].join("],a[href*=\\.")}]").each ->
        $this = $(this)
        $this.addClass("r_image").html("<img src=\"#{$this.attr("href")}\">")
      html = $html.html()


  App.Models.Comment = Comment
  return Comment
