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
    get   '/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session,
      :via => Devise.mappings[:user].sign_out_via

    post    '/users'          => 'registrations#create',  :as => :user_registration
    delete  '/users'          => 'registrations#destroy'
    get     '/users/sign_up'  => 'registrations#new',     :as => :new_user_registration
    get     '/users/cancel'   => 'registrations#cancel',  :as => :cancel_user_registration
    get     '/settings/info'  => 'registrations#edit',    :as => :edit_user_registration
    patch   '/settings/info'  => 'registrations#update'
    get     '/almost_ready'   => 'registrations#almost_ready'
    patch   '/almost_ready'   => 'registrations#almost_ready_update'
  end

  # sitemap
  get '(/sitemaps)/sitemap(:partial).xml(.gz)', :controller => 'sitemap', :action => 'index'

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

  get "/pusher/auth" => "pusher#auth"
  post  "/pusher/existence" => "pusher#existence" # webhook
  get "/support/delete_cookies" => "users#delete_cookies"

  resources :posts
  resources :blogs

  get '/c/:id' => 'comments#shortener'
  get '/:username/comments/:id' => 'comments#show'
  resources :comments

  get '/assets/bookmarklet/loader' => 'extras#bookmarklet_loader'

  # via: http://stackoverflow.com/questions/4273205/rails-routing-with-a-parameter-that-includes-slash
  # Rails or WEBrick for some reason will turn http:// into http:/ so the second / has a ? to make it optional
  # Notice the .rss negative lookahead that allows user RSS feeds to pass through
  # We're not currently supporting (/yn/:yn) "yep . nope" because it should be a user initiated action
  # rather than a trickster potentially formatting a link with yn already in there and promoting a link
  get '(/t/:token)(/p/:id)(/:url)' => 'posts#visit', :constraints => {:url => /(?:(?:http|https|ftp):\/\/?)*[0-9A-Z\-\.]*(?!\.rss)(?:\.[A-Z]+)+.*/i}

  get   '/users/auth/loading/:provider'         => 'authorizations#loading'
  get   '/authorizations/:provider/:uid/places' => 'authorizations#places'
  resources :authorizations

  # via: http://stackoverflow.com/questions/5222760/rails-rest-routing-dots-in-the-resource-item-id
  get '/domains/:domain_name' => 'domains#show', :constraints => { :domain_name => /[0-9A-Z\-\.]+/i }
  resources :domains, :constraints => { :id => /[0-9A-Za-z\-\.]+/ } do
    resources :posts
    resources :pages
  end

  get '/extensions/safari/update' => 'extras#safari_update'

  get "/users"              => redirect("/")
  get '/users/recommended'  => 'users#find_people'
  get '/users/friends'      => 'users#find_people'
  get '/users/search'       => 'users#find_people'
  resources :users do
    get 'tagalong'
    resources :posts
  end

  # Search
  get '/search' => 'search#index'

  resources :hooks
  resources :footnotes

  # Settings
  get '/settings' => 'users#settings'
  get '/settings/hooks'  => 'users#hooks'
  get '/settings/extras' => 'users#extras'

  # Admin
  get '/admin' => redirect('/admin/dashboard')
  get '/admin/dashboard' => 'admin#dashboard'
  get '/admin/jobs' => DelayedJobWeb, anchor: false

  # These routes should be cleaned up
  get '/:username/export'   => 'users#export'
  get '/:username/following'=> 'users#followingers', defaults: { type: 'following' }
  get '/:username/followers'=> 'users#followingers', defaults: { type: 'followers' }
  get '/:username/follow'   => 'relationships#create'
  get '/:username/unfollow' => 'relationships#destroy'
  get '/:username/tumblr'   => 'blogs#show'
  get '/:username/:type(/page/:page)' => 'users#show', constraints: { type: /posts|list/ }
  get '/:username' => 'users#show', defaults: { type: 'posts' }
end
