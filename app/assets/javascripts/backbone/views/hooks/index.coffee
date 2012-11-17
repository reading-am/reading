define [
  "jquery"
  "app/init"
  "app/constants"
  "app/models/current_user"
  "app/helpers/form_builders"
  "app/views/hooks/properties"
], ($, App, Constants, current_user, builders, hook_properties) ->

  # TODO - port this to be a true Backbone View

  # endpoints to get user data from each provider
  api_urls =
    twitter: "https://api.twitter.com/1/users/show.json?id="
    facebook: "https://graph.facebook.com/"

  # replace external account ids with their usernames
  populate_accounts = (provider, selection) ->
    selection.each ->
      $this = $(this)
      unless isNaN $this.text()
        $.ajax
          url: api_urls[provider] + $this.text()
          dataType: "jsonp"
          success: (r) ->
            if r.screen_name
              $this.text (if provider is "twitter" then "@" else "") + r.screen_name
            else if r.username
              $this.text r.username
            else $this.text r.name  if r.name

  build_provider = (prov) ->
    $prov = $("<span>").attr("id", "provider_params")
    count = 0
    for param in prov.params
      $prov.append " using " if count is 1
      $prov.append "<br>"    if count is 2
      $prov.append " and "   if count > 1
      $prov.append builders.field(param, "hook[params]")
      count++ unless param.type? and param.type is "hidden"

    populate_accounts $("#hook_provider").val(), $("[data-type=\"account\"] option[value!=\"new\"]", $prov)
    $prov

  $ ->
    # TODO remove once comments are public and comment hooks are built out 
    events = hook_properties.events
    events.splice(events.length-1,1)

    # build the constructor with the initial selection
    $con = $('#constructor')
    $(".wrapper", $con)
      .append("When I ").append(builders.field({text: "events", options: events}, "hook", false))
      .append(" please post to the ").append(builders.field({text: "provider", options: hook_properties.providers}, "hook", false))
      .append "<span id=\"provider_params\">"

    # switch out and link the footnotes explaining a hook
    $("select[name='hook[provider]']", $con).change(->
      $this = $(this)
      $(".footnote").data "url", "/footnotes/" + $this.val()
      $("#provider_params").replaceWith build_provider(hook_properties.providers[$this.prop("selectedIndex")])
    ).change()

    # switch out and link the footnotes explaining a hook
    $con.on "change", "#hook_provider, #hook_params_account", ->
      $places = $("select[data-src='account.places']")
      if $places.length
        provider = $("#hook_provider").val()
        account  = $("#hook_params_account").val()
        if account is "new"
          $places
            .attr("disabled", "disabled")
            .addClass("disabled")
            .html($("<option>").text "select after connecting")
        else
          $places
            .removeAttr("disabled")
            .removeClass("disabled")
            .html($("<option>").text("Loading...").val(""))
          current_user.get("authorizations")[provider].get(account).places success:(places) ->
            $places.html ""
            $places.append($("<option>").text(place.text).val(place.value)) for place in places
            $places.change() # fire a change event so the hook_params_place_name will get set

    $con.on "change", "#hook_params_place_id", ->
      $("#hook_params_place_name").val($(this).find("option:selected").text())

    # populate the auth spans with real usernames
    populate_accounts "twitter", $(".provider.twitter .account")
    populate_accounts "facebook", $(".provider.facebook .account")

    #########################
    # Process New Hook Form #
    #########################
    $("#new_hook").on "submit", ->
      $this       = $(this)
      $submit     = $this.find(":submit")
      provider    = $("#hook_provider", $this).val()
      prov_cap    = provider[0].toUpperCase() + provider[1..]
      account     = $("#hook_params_account", $this).val()
      permission  = $("#hook_params_permission", $this).val()

      # validate that none of the inputs are empty
      $empty = $this.find(":input[value='']")
      if $empty.length and account isnt "new"
        $("#loading").hide()
        alert "Please specify a " + $("label[for="+$empty.attr("id")+"]").text() + " and resubmit the form"
        false # stop submit

      else if account
        if account is "new"
          auth = new App.Models["#{prov_cap}Auth"](uid: account)
        else
          auth = current_user.get("authorizations")[provider].get(account)

        if not auth.can permission
          $('#loading').fadeIn()
          auth.ask permission, (response) =>
            if account is "new"
              # populate and select the new auth
              $("#hook_params_account")
                .prepend($("<option>").text(auth.name).val(auth.uid))
                .val(auth.uid).change()
            $this.submit()
          , (response) =>
            if account is "new" and auth.uid isnt "new"
              # user approved some of the auth but not the right permissions
              $("#hook_params_account option[value='new']").val auth.uid
            $('#loading').hide()
            alert (Constants.errors[response.status] ? Constants.errors.generic).replace /{provider}/gi, prov_cap

          false # stop submit
