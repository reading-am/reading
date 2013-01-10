define [
  "jquery"
  "backbone"
], ($, Backbone) ->

  class PostNewView extends Backbone.View

    events:
      "click #new_post_button": "toggle_post_form"

    toggle_post_form:(e) ->
      @$("#new_post_row").toggle()
      false
