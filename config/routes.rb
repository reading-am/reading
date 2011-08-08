Reading::Application.routes.draw do
  root :to => "home#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout

  resources :posts
  match '/post' => 'posts#create'
  
  # via: http://stackoverflow.com/questions/4273205/rails-routing-with-a-parameter-that-includes-slash
  # Rails or WEBrick for some reason will turn http:// into http:/ so the second / has a ? to make it optional
  match '(/p/:id)/:url' => 'posts#visit', :constraints => {:url => /(?:(?:http|https|ftp):\/\/?)*[0-9A-Z\-]*(?:\.[A-Z]+)+.*/i}

  resources :hooks

  # via: http://stackoverflow.com/questions/5222760/rails-rest-routing-dots-in-the-resource-item-id
  match '/domains/:domain_name' => 'posts#index', :constraints => { :domain_name => /[0-9A-Z\-\.]+/i }
  resources :domains, :constraints => { :id => /[0-9A-Za-z\-\.]+/ } do
    resources :posts
  end


  match '/pick_a_url' => 'users#pick_a_url'
  match "/users" => redirect("/")
  resources :users do
    resources :posts
  end
  # match '/:username' => 'users#show'
  match '/:username' => 'posts#index'
  match '/:username/settings' => 'users#edit'
  match '/:username/posts' => 'posts#index'


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
