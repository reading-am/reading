define [
  "jquery"
  "backbone"
], ($, Backbone) ->

  class UserShowView extends Backbone.View

    events:
      "click a.follow": "follow"

    initialize: ->
      @$followers_count = @$("#followers_count")

    follow:(e) ->
      $target = $(e.currentTarget)
      follow = "Follow"
      disabled = "disabled"

      return false if $target.hasClass(disabled)
      $target.addClass disabled

      $.get $target.attr("href"), (data) =>
        $target.removeClass disabled

        if data is "true"
          $span = $target.find("span")
          followed = $span.text().indexOf(follow) is 0
          text = if followed then "Un" + follow.toLowerCase() else follow
          href = $target.attr("href")

          $target.attr("href", href.replace($span.text().toLowerCase(), text.toLowerCase()))
          $span.text(text)
          @$followers_count.text(Number(@$followers_count.text()) + (if followed then 1 else -1))

      false
