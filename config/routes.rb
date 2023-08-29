#==
# Copyright (C) 2010-2023 James S Urquhart
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

Rucksack::Application.routes.draw do
  resource :settings, :controller => 'accounts', :as => :account

  resource :dashboard
  resources :reminders do
    member do
      put :snooze
    end
  end
  
  resource :status
  resources :journals
  
  resources :users do
                                  
    collection do
      get :forgot_password
      put :forgot_password
      post :forgot_password
      get :reset_password
      put :reset_password
      post :reset_password
      get :current
    end
    
    resources :journals
    resources :reminders
    resources :pages
    resource :dashboard
    resource :status
  end
  
  resources :pages do
    member do
      post :reorder 
      put :transfer
      put :favourite
      post :duplicate
      get :share
      put :share
      post :share
      get :public
      put :resize
      put :reset_address
      get :tags
      put :tags
      post :tags
    end
    
    collection do
      get :current
      post :reorder_sidebar
    end
    
    resources :lists do
      member do
        post :reorder
        put :transfer
      end
      resources :items, :controller => 'list_items', :as => 'list_items' do
        member do
          put :status
        end
      end
    end
    
    resources :notes
    resources :separators
    resources :emails do
      member do
        get :public
      end
    end
    
    resources :uploaded_files
    resources :albums do
      member do
        post :reorder
        put :transfer
      end
      resources :pictures, :controller => 'album_pictures', :as => :album_pictures
    end
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  match '/', :controller => "pages", :action => "current", :as => :root, :via => :get

  # Restful authentication
  resource :session
  match '/login',  :controller => 'sessions', :action => 'new', :as => :login, :via => :get
  match '/logout', :controller => 'sessions', :action => 'destroy', :as => :logout, :via => :get

  # See how all your routes lay out with "rake routes"
  
  # 404 icons
  match '/images/file_icons/:id.png', :controller => 'uploaded_files', :action => 'icon', :via => :get

  # Install the default routes as the lowest priority.
  match ':controller/:action/:id', :via => :get
  match ':controller/:action/:id.:format', :via => :get
end
