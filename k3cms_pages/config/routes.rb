Rails.application.routes.draw do
  resources :k3_pages, :controller => 'k3/pages/pages' do
    collection do
      get :not_found
    end
  end
end
