Jijing::Application.routes.draw do
  root :to => 'site#index', :as => 'home'
  
  devise_for :users
  devise_for :users, :controllers => {:sessions => 'devise/sessions'}, :skip => [:sessions] do
    get 'login' => 'devise/sessions#new', :as => :login
    post 'login' => 'devise/sessions#create', :as => :user_session
    get 'logout' => 'devise/sessions#destroy', :as => :logout
    get 'signup' => 'devise/registrations#new', :as => :signup
  end


  resources :posts

  get "bookmarklets/login"

  get "bookmarklets/do_login"

  get "bookmarklets/new_post"

  get "bookmarklets/create_post"

  get "bookmarklets/jijing_bookmarklet"

  match 'explore', :to => 'site#explore', :as => 'explore'
  match 'about',   :to => 'site#about',   :as => 'about'
  match 'help',    :to => 'site#help',    :as => 'help'
  match 'tools',   :to => 'site#tools',   :as => 'tools'
  match 'blog',    :to => 'site#blog',    :as => 'blog'

  match 'tags/:id', :to => 'tags#show', :as => 'tag'
  match 'tags/:id/u/:user_id', :to => 'tags#show', :as => 'tag_by_user'

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
