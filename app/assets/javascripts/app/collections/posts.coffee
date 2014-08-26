define [
  "underscore"
  "backbone"
  "app/init"
  "app/models/post"
], (_, Backbone, App, Post) ->

  class App.Collections.Posts extends Backbone.Collection
    type: "Posts"
    model: Post

    comparator: (post) -> -(post.get("created_at") || new Date)

    # there's a companion method in posts_helper.rb
    yn_average: ->
      the_sum = 0
      total_count = 0
      @each (post) ->
        if post.get("yn") is null
          next_value = 0
        else
          next_value = post.get("yn") ? 1 : -1

        the_sum += next_value
        total_count += 1

      return 0 unless total_count > 0
      the_sum / total_count

    endpoint: ->
      "#{
        super()
      }#{
        if @medium and @medium isnt "all" then "/#{@medium}" else ""
      }"
