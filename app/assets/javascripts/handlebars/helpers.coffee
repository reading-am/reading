Handlebars.registerHelper "nl2br", (context, fn) ->
  new Handlebars.SafeString (context+"").replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1<br>$2")

Handlebars.registerHelper "autolink", (context, fn) ->
  new Handlebars.SafeString twttr.txt.autoLink context,
      urlClass:       "r_url",
      usernameClass:  "r_mention",
      hashtagClass:   "r_tag",
      usernameUrlBase:"//<%= DOMAIN %>/",
      listUrlBase:    "//<%= DOMAIN %>/",
      hashtagUrlBase: "//<%= DOMAIN %>/search?q="

Handlebars.registerHelper "embed_images", (context, fn) ->
  $context = ø.$("<div>#{context}</div>")
  $context.find("a[href$=#{["jpg","jpeg","png","gif"].join("],a[href$=")}]").each ->
    $this = ø.$(this)
    $this.html("<img src=\"#{$this.attr("href")}\">")
  new Handlebars.SafeString $context.html()

Handlebars.registerHelper 'format_comment', (context, fn) ->
  context = Handlebars.helpers.nl2br.call this, context, fn
  context = Handlebars.helpers.autolink.call this, context.string, fn
  context = Handlebars.helpers.embed_images.call this, context.string, fn
  context
