json.type       'OauthAccessToken'
json.token      token.token
json.app        { json.partial! 'oauth_applications/oauth_application', app: token.application }
json.created_at token.created_at
json.scopes     token.scopes
