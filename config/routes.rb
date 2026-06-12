Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  scope controller: :main do
    get :projects
    get :tasks
    get :transfers
    get :messages
    get :history
    get :notices
  end
  resources :computers, only: [:index]
  #resources :tasks, only: [:index, :show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "main#index"
end
