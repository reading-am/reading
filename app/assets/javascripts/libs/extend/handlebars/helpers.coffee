define [
  "jquery"
  "underscore"
  "app/constants"
  "libs/handlebars"
  "libs/twitter-text"
], ($, _, Constants, Handlebars, TwitterText) ->

  Handlebars.registerHelper "nl2br", (context, fn) ->
    new Handlebars.SafeString (context+"").replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1<br>$2")

  Handlebars.registerHelper "autolink", (context, fn) ->
    new Handlebars.SafeString TwitterText.autoLink context,
        urlClass:       "r_url",
        usernameClass:  "r_mention",
        hashtagClass:   "r_tag",
        usernameUrlBase:"//#{Constants.domain}/",
        listUrlBase:    "//#{Constants.domain}/",
        hashtagUrlBase: "//#{Constants.domain}/search?q="


  Handlebars.registerHelper "embed_images", (context, fn) ->
    $context = $("<div>#{context}</div>")
    $context.find("a[href*=\\.#{["jpg","jpeg","png","gif"].join("],a[href*=\\.")}]").each ->
      $this = $(this)
      $this.addClass("r_image").html("<img src=\"#{$this.attr("href")}\">")
    new Handlebars.SafeString $context.html()

  Handlebars.registerHelper "link_emails", (context, fn) ->
    re = /(([a-z0-9*._+]){1,}\@(([a-z0-9]+[-]?){1,}[a-z0-9]+\.){1,}([a-z]{2,4}|museum)(?![\w\s?&.\/;#~%"=-]*>))/g
    new Handlebars.SafeString context.replace re,'<a href="mailto:$1" class="r_email">$1</a>'

  Handlebars.registerHelper "wrap_code", (context, fn) ->
    re = /`((?:[^`]+|\\.)*)`/g
    new Handlebars.SafeString context.replace re,'<pre><code>$1</code></pre>'

  Handlebars.registerHelper "link_quotes", (context, fn) ->
    matches = context.match(/"(?:[^\\"]+|\\.)*"/gi)

    if matches
      cname = "r_quoted"
      config = className: cname
      $body = $("body > *:not(#r_am)")

      matches = _(matches).map (text) -> text.substring(1, text.length-1)
      matches = _(matches).filter (text) ->
        $body.highlight text, config
        if $body.find(".#{cname}").length
          $body.unhighlight config
        else
          false

      if matches
        $context = $("<div>#{context}</div>")
        config.element = "a"
        $context.highlight matches, config
        $context.find(".#{cname}").attr(href: "#")
        context = $context.html()

    new Handlebars.SafeString context

  Handlebars.registerHelper 'multi_show', (context, fn) ->
    #TODO i could probably just make the formatting a Handlebars Helper
    # On second thought I think this is a lot slower so I'll let Greg choose
    ###
      @<a class="r_url r_mention" data-screen-name="two" href="//0.0.0.0:3000/two" rel="nofollow">two</a> 
      @<a class="r_url r_mention" data-screen-name="three" href="//0.0.0.0:3000/three" rel="nofollow">three</a> 
      @<a class="r_url r_mention" data-screen-name="four" href="//0.0.0.0:3000/four" rel="nofollow">four</a>
    ###



    $context = $("<div>#{context}</div>")
    mentions = $context.children('.r_mention').length
    words = $context.children().length
    new_context = ""
    if $context.children().length == $context.children('.r_mention').length
      for index, mention in mentions
        if index is mentions.length-1 
          new_context += "and #{mention}"
        else
          new_context += "#{mention},"

      
    context = $context.html()

  Handlebars.registerHelper 'format_comment', (context, fn) ->
    context = Handlebars.helpers.nl2br.call this, context, fn
    context = Handlebars.helpers.link_emails.call this, context.string, fn
    context = Handlebars.helpers.link_quotes.call this, context.string, fn
    context = Handlebars.helpers.wrap_code.call this, context.string, fn
    context = Handlebars.helpers.autolink.call this, context.string, fn
    context = Handlebars.helpers.embed_images.call this, context.string, fn
    context = Handlebars.helpers.multi_show.call this, context.string, fn
    context

  return Handlebars
