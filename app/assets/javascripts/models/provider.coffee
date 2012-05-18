define [
  "app"
], (App) ->

  class App.Models.Provider
    accounts: ->
      {text:val.name, value:val.uid} for own key, val of this

  # from: http://stackoverflow.com/questions/4358135/how-to-make-omniauth-work-with-a-popup-window
  App.Models.Provider::login = (params, response) ->
    # TODO I don't like that this is scoped to Provider
    # but it works as a shared space for the redirect.html.erb response
    App.Models.Provider::login.response = response ? ->

    screenX = window.screenX ? window.screenLeft
    screenY = window.screenY ? window.screenTop
    outerWidth = window.outerWidth ? document.body.clientWidth
    outerHeight = window.outerHeight ? (document.body.clientHeight - 22)
    left = parseInt(screenX + ((outerWidth - params.width) / 2), 10)
    top = parseInt(screenY + ((outerHeight - params.height) / 2.5), 10)
    popup = window.open params.url, "Login", "width=#{params.width},height=#{params.height},left=#{left},top=#{top}"
    popup.focus() if window.focus
    false

  return App.Models.Provider
