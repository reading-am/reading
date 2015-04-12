json.type       'OauthAccessToken'
json.token      oauth_access_token.token
json.app        { json.partial! 'oauth_applications/oauth_application', oauth_application: oauth_access_token.application }
json.created_at oauth_access_token.created_at
json.scopes     oauth_access_token.scopes
