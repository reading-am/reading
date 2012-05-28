define [
  "handlebars"
  "app/views/components/popover"
  "app/models/provider"
  "app/collections/providers"
  "app/views/providers/providers"
], (Handlebars, Popover, Provider, Providers, ProvidersView) ->

  class SharePopover extends Popover
    template: Handlebars.compile "
      <ul id=\"r_share_menu\"></ul>
      <div class=\"r_blocker\"></div>
    "

    id: "r_share_popover"
    className: "r_popover"

    events:
      "click" : "close"

    initialize: (options) ->
      popup = (url, width, height) ->
        window.open url, "r_win", "location=0,toolbars=0,status=0,directories=0,menubar=0,resizable=0,width=#{width},height=#{height}"

      @providers = new Providers [
        {
          name: "Twitter"
          url_scheme: "https://twitter.com/share?url={{short_url}}&text=✌%20Reading%20%22{{title}}%22"
          action: (url) ->
            popup url, 475, 345
        },{
          name: "Facebook"
          url_scheme: "https://www.facebook.com/sharer.php?u={{wrapped_url}}&t={{title}}"
          action: (url) ->
            popup url, 520, 370
        },{
          name: "Tumblr"
          url_scheme: "http://www.tumblr.com/share?v=3&u={{wrapped_url}}&t=✌%20Reading%20%22{{title}}%22"
          action: (url) ->
            popup url, 450, 430
        },{
          name: "Instapaper"
          url_scheme: "http://www.instapaper.com/hello2?url={{url}}&title={{title}}"
          action: (url) ->
            window.location = url
        },{
          name: "Readability"
          url_scheme: "http://www.readability.com/save?url={{url}}"
          action: (url) ->
            window.location = url
        },{
          name: "Pocket"
          url_scheme: "https://getpocket.com/save?url={{url}}&title={{title}}"
          action: (url) ->
            popup url, 490, 400
        },{
          name: "Pinboard"
          url_scheme: "https://pinboard.in/add?showtags=yes&url={{url}}&title={{title}}&tags=reading.am"
          action: (url) ->
            popup url, 490, 400
        },{
          name: "Email"
          url_scheme: "mailto:?subject=✌%20Reading%20%22{{title}}%22&body={{wrapped_url}}"
          action: (url) ->
            window.location.href = url
        }
      ]

    render: ->
      super

      @providers_view = new ProvidersView
        el: @$("#r_share_menu")
        collection: @providers

      @providers_view.render()
