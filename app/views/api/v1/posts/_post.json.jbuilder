json.type        "Post"
json.id          post.id
json.title       post.page.display_title
json.url         post.page.url
json.yn          post.yn
json.wrapped_url post.wrapped_url
json.created_at  post.created_at
json.updated_at  post.updated_at
json.user { json.partial! 'users/user', user: post.user }
json.page { json.partial! 'pages/page', page: post.page }

if post.referrer_post.present?
  json.referrer_post do
    json.type "Post"
    json.id   post.referrer_post.id
    json.user { json.partial! 'users/user_bare', user: post.referrer_post.user }
  end
end
