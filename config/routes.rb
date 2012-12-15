Reading::Application.routes.draw do
  root :to => "posts#index"

  devise_for :users,
    :skip => [:sessions,:registrations],
    :controllers => {
      :registrations => 'registrations',
      :omniauth_callbacks => 'omniauth'
    }
  # via: https://github.com/plataformatec/devise/wiki/How-To:-Change-the-default-sign_in-and-sign_out-routes/8c1825a5ba0b2fbe2f91a1c39aea0808a168800a
  as :user do
    get   '/sign_in'  => 'devise/sessions#new',     :as => :new_user_session
    post  '/sign_in'  => 'devise/sessions#create',  :as => :user_session
    match '/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session,
      :via => Devise.mappings[:user].sign_out_via

    post    '/users'          => 'registrations#create',  :as => :user_registration
    delete  '/users'          => 'registrations#destroy'
    get     '/users/sign_up'  => 'registrations#new',     :as => :new_user_registration
    get     '/users/cancel'   => 'registrations#cancel',  :as => :cancel_user_registration
    get     '/settings/info'  => 'registrations#edit',    :as => :edit_user_registration
    put     '/settings/info'  => 'registrations#update'
    get     '/almost_ready'   => 'registrations#almost_ready'
    put     '/almost_ready'   => 'registrations#almost_ready_update'
  end

  # sitemap
  match '(/sitemaps)/sitemap(:partial).xml(.gz)', :controller => 'sitemap', :action => 'index'

  # api
  namespace :api, :defaults => { :format => 'json' } do
    resources :posts do
      get 'count', :on => :collection
    end
    resources :comments do
      get 'count', :on => :collection
    end
    resources :users do
      get 'count', :on => :collection
      get 'search', :on => :collection
      get 'recommended', :on => :collection
      resources :posts
      resources :comments
      resources :events, :controller => 'posts'
      get 'expats', :on => :member
      resources :following, :controller => 'users', :defaults => { :type => 'following' } do
        get 'events', :on => :collection, :controller => 'posts', :action => 'index'
      end
      resources :followers, :controller => 'users', :defaults => { :type => 'followers' }
    end
    resources :pages do
      get 'count', :on => :collection
      get 'search', :on => :collection
      resources :users
      resources :comments
      resources :posts
    end
  end

  match "/pusher/auth" => "pusher#auth"
  match "/support/delete_cookies" => "users#delete_cookies"

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

  match '/users/auth/loading/:provider'         => 'authorizations#loading'
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

  match "/users"              => redirect("/")
  match '/users/recommended'  => 'users#find_people'
  match '/users/friends'      => 'users#find_people'
  match '/users/search'       => 'users#find_people'
  resources :users do
    get 'tagalong'
    resources :posts
  end

  # Search
  match '/search' => 'search#index'

  resources :hooks
  resources :footnotes

  # Settings
  match '/settings' => 'users#settings'
  match '/settings/hooks'  => 'users#hooks'
  match '/settings/extras' => 'users#extras'

  # Admin
  match '/admin' => redirect('/admin/dashboard')
  match '/admin/dashboard' => 'admin#dashboard'
  match '/admin/jobs' => DelayedJobWeb, :anchor => false

  # These routes should be cleaned up
  match '/:username(/posts)(/posts/page/:page)'  => 'users#show', :defaults => { :type => 'posts' }
  match '/:username/list(/page/:page)'     => 'users#show', :defaults => { :type => 'list' }
  match '/:username/export'   => 'users#export'
  match '/:username/following'=> 'users#followingers', :defaults => { :type => 'following' }
  match '/:username/followers'=> 'users#followingers', :defaults => { :type => 'followers' }
  match '/:username/follow'   => 'relationships#create'
  match '/:username/unfollow' => 'relationships#destroy'
end
