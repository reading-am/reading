medium_constraints = { medium: /#{Page::MEDIUMS.join('|')}/ }

Reading::Application.routes.draw do
  root to: "users#show"

  devise_for :users,
    skip: [:sessions,:registrations],
    controllers: {
      registrations: 'registrations',
      omniauth_callbacks: 'omniauth'
    }
  # via: https://github.com/plataformatec/devise/wiki/How-To:-Change-the-default-sign_in-and-sign_out-routes/8c1825a5ba0b2fbe2f91a1c39aea0808a168800a
  as :user do
    get   '/sign_in'  => 'devise/sessions#new',     as: :new_user_session
    post  '/sign_in'  => 'devise/sessions#create',  as: :user_session
    get   '/sign_out' => 'devise/sessions#destroy', as: :destroy_user_session,
      :via => Devise.mappings[:user].sign_out_via

    post    '/users'          => 'registrations#create',  as: :user_registration
    delete  '/users'          => 'registrations#destroy'
    get     '/users/sign_up'  => 'registrations#new',     as: :new_user_registration
    get     '/users/cancel'   => 'registrations#cancel',  as: :cancel_user_registration
    get     '/settings/info'  => 'registrations#edit',    as: :edit_user_registration
    patch   '/settings/info'  => 'registrations#update'
    get     '/almost_ready'   => 'registrations#almost_ready'
    patch   '/almost_ready'   => 'registrations#almost_ready_update'
  end

  # sitemap
  get '(/sitemaps)/sitemap(:partial).xml(.gz)' => 'sitemap#index'

  concern :api_v1_users do
    get 'expats' # move this to /user
    resources :comments
    resources :posts, only: :index do
      get ':medium',
          on: :collection,
          action: 'index',
          constraints: medium_constraints
    end
    resources :following,
              controller:   'relationships',
              defaults:     { type: 'following' },
              constraints:  { type: 'following' } do
      # Using a get string here rather than resources
      # because rails limits nesting of resources
      get 'posts(/:medium)',
          on:         :collection,
          controller: 'posts',
          action:     'index',
          constraints: medium_constraints
    end
    resources :followers,
              controller:   'relationships',
              defaults:     { type: 'followers' },
              constraints:  { type: 'followers' }
    resources :blocking,
              controller:   'blockages',
              defaults:     { type: 'blocking' },
              constraints:  { type: 'blocking' }
    resources :blockers,
              controller:   'blockages',
              defaults:     { type: 'blockers' },
              constraints:  { type: 'blockers' }
  end

  # api
  concern :api do
    api_version(module: 'Api::V1',
                header: { name: 'Accept', value: 'application/vnd.reading.v1' },
                defaults: { format: 'json' },
                default: true) do
      # No content at root - send to our primary domain
      get '/', to: redirect("//#{ENV['APP_ROOT_URL']}")
      resources :posts do
        get 'stats', on: :collection
        get ':medium',
            on:          :collection,
            action:      'index',
            constraints: medium_constraints
      end
      resources :comments do
        get 'stats',    on: :collection
      end
      resource :user, defaults: { add_current_user_id: true } do
        concerns :api_v1_users
      end
      resources :users do
        get 'stats',       on: :collection
        get 'search',      on: :collection
        get 'recommended', on: :collection
        concerns :api_v1_users
      end
      resources :pages do
        get 'stats', on: :collection
        resources :users, only: :index
        resources :comments, only: :index
        resources :posts, only: :index
      end
      resources :domains do
        get 'stats', on: :collection
        resources :posts, only: :index do
          get ':medium',
              on: :collection,
              action: 'index',
              constraints: medium_constraints
        end
      end
      resources :oauth_access_tokens
      resources :oauth_applications
    end
  end

  constraints subdomain: 'api' do
    concerns :api
  end

  scope :api do
    concerns :api
  end

  post "/pusher/auth"            => "pusher#auth"
  post "/pusher/existence"       => "pusher#existence" # webhook
  get  "/support/delete_cookies" => "users#delete_cookies"
  get  "/support/suspended"      => "users#suspended"

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
  get '(/t/:token)(/p/:id)(/:url)' => 'posts#visit', constraints: { url: /(?:(?:http|https|ftp):\/\/?)*[0-9A-Z\-\.]*(?!\.rss)(?:\.[A-Z]+)+.*/i }

  get   '/users/auth/loading/:provider'         => 'authorizations#loading'
  get   '/authorizations/:provider/:uid/places' => 'authorizations#places'
  resources :authorizations

  # via: http://stackoverflow.com/questions/5222760/rails-rest-routing-dots-in-the-resource-item-id
  resources :domains, constraints: { id: /[0-9A-Z\-\.]+/i } do
    member do
      get '(/:type)(/posts)(/:medium)(/page/:page)' => 'domains#show',
        defaults: { type: 'posts' },
        constraints: { type: /posts|list|following/ }
    end
    resources :posts
    resources :pages
  end

  get '/extensions/safari/update' => 'extras#safari_update'

  get "/users"              => redirect("/")
  get '/users/recommended'  => 'users#recommended'
  get '/users/friends'      => 'users#expats'
  get '/users/search'       => 'users#search'
  resources :users do
    get 'tagalong'
    resources :posts
  end

  resources :hooks
  resources :footnotes

  # Settings
  get '/settings'        => 'users#settings'
  get '/settings/hooks'  => 'users#hooks'
  get '/settings/apps'   => 'users#apps'
  get '/settings/apps/dev' => 'users#dev_apps'
  get '/settings/extras' => 'users#extras'

  # Admin
  get '/admin' => redirect('/admin/dashboard')
  get '/admin/dashboard' => 'admin#dashboard'
  get '/admin/jobs' => DelayedJobWeb, anchor: false
  get '/admin/become/:username' => 'admin#become'

  # These routes should be cleaned up
  get '/:username/export'   => 'export#index'
  get '/:username/following'=> 'users#followingers', defaults: { type: 'following' }
  get '/:username/followers'=> 'users#followingers', defaults: { type: 'followers' }
  get '/:username/tumblr'   => 'blogs#show'
  get '/:username(/:type)(/posts)(/:medium)(/:yn)(/page/:page)' => 'users#show',
    defaults: { type: 'posts' },
    constraints: { type: /posts|list|following/,
                   medium: medium_constraints[:medium],
                   yn: /any|yeps|nopes|neutral/ }
end
