Reading::Application.routes.draw do
  root :to => "posts#index"

  # sitemap
  match '(/sitemaps)/sitemap(:partial).xml(.gz)', :controller => 'sitemap', :action => 'index'

  # api
  namespace :api, :defaults => { :format => 'json' } do
    resources :posts
    resources :comments
    resources :users do
      resources :posts
      resources :comments
    end
    resources :pages do
      resources :users
      resources :comments
    end
  end

  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"
  match "/signout" => "sessions#destroy", :as => :signout
  match "/support/delete_cookies" => "users#delete_cookies"

  match '/posts/create' => 'posts#create'
  match '/posts/:id/update' => 'posts#update'
  resources :posts

  match '/comments/create' => 'comments#create'
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

  match '/pick_a_url' => 'users#pick_a_url'
  match "/users" => redirect("/")
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


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
