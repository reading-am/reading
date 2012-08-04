Reading::Application.routes.draw do
  root :to => "posts#index"

  # sitemap
  match '(/sitemaps)/sitemap(:partial).xml(.gz)', :controller => 'sitemap', :action => 'index'

  # api
  namespace :api, :defaults => { :format => 'json' } do
    resources :posts
    resources :comments
    resources :users do
      get 'search', :on => :collection
      get 'recommended', :on => :collection
      resources :posts
      resources :comments
      get 'expats', :on => :member
      resources :following, :controller => "users", :defaults => { :type => "following" }
      resources :followers, :controller => "users", :defaults => { :type => "followers" }
    end
    resources :pages do
      get 'search', :on => :collection
      resources :users
      resources :comments
    end
  end

  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/signout" => "sessions#destroy", :as => :signout

  match "/support/delete_cookies" => "support#delete_cookies"
  match "/support/204" => "support#twozerofour"

  match '/posts/create' => 'posts#create'
  match '/posts/:id/update' => 'posts#update'
  resources :posts

  match '/comments/create' => 'comments#create'
  match '/c/:id' => 'comments#shortener'
  match '/:username/comments/:id' => 'comments#show'
  resources :comments

  # via: http://stackoverflow.com/questions/4273205/rails-routing-with-a-parameter-that-includes-slash
  # Rails or WEBrick for some reason will turn http:// into http:/ so the second / has a ? to make it optional
  # Notice the .rss negative lookahead that allows user RSS feeds to pass through
  # We're not currently supporting (/yn/:yn) "yep . nope" because it should be a user initiated action
  # rather than a trickster potentially formatting a link with yn already in there and promoting a link
  match '(/t/:token)(/p/:id)(/:url)' => 'posts#visit', :constraints => {:url => /(?:(?:http|https|ftp):\/\/?)*[0-9A-Z\-\.]*(?!\.rss)(?:\.[A-Z]+)+.*/i}

  match '/auth/loading/:provider' => 'authorizations#loading'
  match '/authorizations/:provider/:uid/update' => 'authorizations#update'
  match '/authorizations/:provider/:uid/places' => 'authorizations#places'
  resources :authorizations

  # via: http://stackoverflow.com/questions/5222760/rails-rest-routing-dots-in-the-resource-item-id
  match '/domains/:domain_name' => 'domains#show', :constraints => { :domain_name => /[0-9A-Z\-\.]+/i }
  resources :domains, :constraints => { :id => /[0-9A-Za-z\-\.]+/ } do
    resources :posts
    resources :pages
  end

  match '/extensions/safari/update' => 'extras#safari_update'

  match '/almost_ready'       => 'users#almost_ready'
  match "/users"              => redirect("/")
  match '/users/recommended'  => 'users#find_people'
  match '/users/friends'      => 'users#find_people'
  match '/users/search'       => 'users#find_people'
  resources :users do
    resources :posts
  end

  # Search
  match '/search' => 'search#index'

  resources :hooks
  resources :footnotes
  
  # Settings
  match '/settings' => 'users#settings'
  match '/settings/info' => 'users#edit'
  match '/settings/hooks'  => 'users#hooks'
  match '/settings/extras' => 'users#extras'

  # These routes should be cleaned up
  match '/:username(/posts)(/posts/page/:page)'  => 'users#show', :defaults => { :type => 'posts' }
  match '/:username/list(/page/:page)'     => 'users#show', :defaults => { :type => 'list' }
  match '/:username/export'   => 'users#export'
  match '/:username/following'=> 'users#followingers', :defaults => { :type => 'following' }
  match '/:username/followers'=> 'users#followingers', :defaults => { :type => 'followers' }
  match '/:username/follow'   => 'relationships#create'
  match '/:username/unfollow' => 'relationships#destroy'
end
