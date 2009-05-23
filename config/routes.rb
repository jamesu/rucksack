#==
# Copyright (C) 2008 James S Urquhart
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#++

ActionController::Routing::Routes.draw do |map|
  map.resource :account, :as => 'settings'

  map.resource :dashboard
  map.resources :reminders, :member => {:snooze => :put}
  
  map.resource :status
  map.resources :journals

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  map.resources :users,
                :collection => {:forgot_password => :any,
                                :reset_password => :any,
                                :current => :get} do |users|
    users.resources :journals
    users.resources :reminders
    users.resources :pages
    users.resource :dashboard
    users.resource :status
  end
  
  map.resources :pages, :member => {:reorder => :post, 
                                    :reorder_sidebar => :post,
                                    :transfer => :put,
                                    :favourite => :put,
                                    :duplicate => :post,
                                    :share => :any,
                                    :public => :get,
                                    :resize => :put,
                                    :reset_address => :put,
                                    :tags => :any}, :collection => {:current => :get} do |page|
    page.resources :lists, :member => {:reorder => :post, :transfer => :put} do |list|
        list.resources :list_items, :as => 'items', :member => {:status => :put}
    end
    page.resources :notes
    page.resources :separators
    page.resources :emails, :member => {:public => :get}
    page.resources :uploaded_files
    page.resources :albums, :member => {:reorder => :post, :transfer => :put} do |album|
        album.resources :album_pictures, :as => 'pictures'
    end
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "pages", :action => "current"

  # Restful authentication
  map.resource :session
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # See how all your routes lay out with "rake routes"
  
  # 404 icons
  map.connect '/images/file_icons/:id.png', :controller => 'uploaded_files', :action => 'icon'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
