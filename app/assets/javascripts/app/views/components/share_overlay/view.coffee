define [
  "app/views/components/overlay/view"
  "app/models/provider"
  "app/collections/providers"
  "app/views/providers/providers/view"
  "text!app/views/components/share_overlay/template.mustache"
  "text!app/views/components/share_overlay/styles.css"
], (Overlay, Provider, Providers, ProvidersView, template, styles) ->

  class ShareOverlay extends Overlay
    @assets
      styles: styles
      template: template

    events:
      "click" : "close"

    initialize: (options) ->
      super options

      popup = (url, width, height) ->
        window.open url, "r_win", "location=0,toolbars=0,status=0,directories=0,menubar=0,resizable=0,width=#{width},height=#{height}"

      @providers = new Providers [
        {
          subject: options.subject
          name: "Twitter"
          url_scheme: "https://twitter.com/share?url={{short_url}}&text=✌%20%40Reading%20{{title}}"
          action: ->
            popup @url(), 475, 345
        },{
          subject: options.subject
          name: "Facebook"
          url_scheme: "https://www.facebook.com/sharer.php?u={{wrapped_url}}&t={{title}}"
          action: ->
            popup @url(), 520, 370
        },{
          subject: options.subject
          name: "Tumblr"
          url_scheme: "http://www.tumblr.com/share?v=3&u={{wrapped_url}}&t=✌%20Reading%20{{title}}"
          action: ->
            popup @url(), 450, 430
        },{
          subject: options.subject
          name: "Google +"
          url_scheme: "https://plus.google.com/share?url={{wrapped_url}}"
          action: ->
            popup @url(), 500, 450
        },{
          subject: options.subject
          name: "Instapaper"
          url_scheme: "http://www.instapaper.com/hello2?url={{url}}&title={{title}}"
          action: ->
            window.location = @url()
        },{
          subject: options.subject
          name: "Readability"
          url_scheme: "http://www.readability.com/save?url={{url}}"
          action: ->
            window.location = @url()
        },{
          subject: options.subject
          name: "Pocket"
          url_scheme: "https://getpocket.com/save?url={{url}}&title={{title}}"
          action: ->
            popup @url(), 490, 400
        },{
          subject: options.subject
          name: "Pinboard"
          url_scheme: "https://pinboard.in/add?showtags=yes&url={{url}}&title={{title}}&tags=reading.am"
          action: ->
            popup @url(), 490, 400
        },{
          subject: options.subject
          name: "App.net α"
          url_scheme: "https://alpha.app.net/intent/post?text=✌%20Reading%20{{title}}%20{{short_url}}"
          action: ->
            popup @url(), 475, 345
        },{
          subject: options.subject
          name: "Email"
          url_scheme: "mailto:?subject=✌%20Reading%20{{title}}&body={{wrapped_url}}"
          action: ->
            window.location.href = @url()
        }
      ]

    render: ->
      super()

      @providers_view = new ProvidersView
        el: @$("#r_share_menu")
        collection: @providers

      @providers_view.render()
