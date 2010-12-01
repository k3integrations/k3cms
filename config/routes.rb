Rails.application.routes.draw do
  match '/pages/not_found' => 'k3/pages/pages#not_found'
  resources :pages, :controller => 'k3/pages/pages'
end
