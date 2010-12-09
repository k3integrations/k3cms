Rails.application.routes.draw do
  #match '/some_bogus_route' => 'k3/pages/pages#index'
  match '/pages/not_found' => 'k3/pages/pages#not_found'
  resources :pages, :controller => 'k3/pages/pages'
  resources :k3_pages, :controller => 'k3/pages/pages'
end
