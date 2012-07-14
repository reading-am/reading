reading.define [
  "app/init"
], (App) ->

  class Provider
    accounts: ->
      {text:val.name, value:val.uid} for own key, val of this

  # from: http://stackoverflow.com/questions/4358135/how-to-make-omniauth-work-with-a-popup-window
  Provider::login = (params, response) ->
    # TODO I don't like that this is scoped to window
    # but it works as a shared space for the redirect.html.erb response
    window.provider_response = response ? ->

    screenX = window.screenX ? window.screenLeft
    screenY = window.screenY ? window.screenTop
    outerWidth = window.outerWidth ? document.body.clientWidth
    outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
    left = parseInt(screenX + ((outerWidth - params.width) / 2), 10)
    top = parseInt(screenY + ((outerHeight - params.height) / 2.5), 10)
    popup = window.open params.url, "Login", "width=#{params.width},height=#{params.height},left=#{left},top=#{top}"
    popup.focus() if window.focus
    false

  App.Models.Provider = Provider
  return Provider
