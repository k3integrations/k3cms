Rails.application.routes.draw do
  resources :k3cms_pages, :controller => 'k3cms/pages/pages' do
    collection do
      get :not_found
    end
  end
end
