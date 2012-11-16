define [
  "jquery"
  "backbone"
  "app/constants"
], ($, Backbone, Constants) ->

  class UserShowView extends Backbone.View

    events:
      "click a.follow": "follow"

    initialize: ->
      $ -> if Constants.env is "development"
        # replace images from production S3 account
        $("img").error ->
          $this = $(this)
          $this.unbind("error").attr("src", $this.attr("src").replace("development","production"))

    follow:(e) ->
      $target = $(e.currentTarget)
      follow = "Follow"
      disabled = "disabled"

      return false if $target.hasClass(disabled)
      $target.addClass disabled

      $.get $target.attr("href"), (data) ->
        if data is "true"
          $span = $target.find("span")
          text = (if $span.text().indexOf(follow) is 0 then "Un" + follow.toLowerCase() else follow)
          href = $target.attr("href")
          $target.attr "href", href.replace($span.text().toLowerCase(), text.toLowerCase())
          $span.text text
        $target.removeClass disabled

      false
