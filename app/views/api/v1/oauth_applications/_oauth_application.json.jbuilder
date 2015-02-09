json.type           'OauthApp'
json.consumer_key   app.uid
json.name           app.name
json.description    app.description
json.website        app.website
json.redirect_uri   app.redirect_uri
json.app_store_url  app.app_store_url
json.play_store_url app.play_store_url
json.icon_medium    app.icon_url(:medium)
json.icon_thumb     app.icon_url(:thumb)
json.icon_mini      app.icon_url(:mini)
json.created_at     app.created_at
json.updated_at     app.updated_at
