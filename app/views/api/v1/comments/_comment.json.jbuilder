json.type        "Comment"
json.id          comment.id
json.body        comment.body
                 # needs to be http for the iframe
json.url         "http://#{DOMAIN}/#{comment.user.username}/comments/#{comment.id}"
json.created_at  comment.created_at
json.updated_at  comment.updated_at
json.user        { json.partial! 'users/user', user: comment.user }
json.user        { json.partial! 'pages/page', page: comment.page }
