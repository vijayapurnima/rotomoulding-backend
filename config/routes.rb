Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'unused#unused'

  scope defaults: {format: :json} do

    get 'users/get_staff', controller: :users, action: :get_staff


    post 'logins', controller: :logins, action: :login
    get 'logins/loggedIn', controller: :logins, action: :loggedIn
    delete 'logins/:id', controller: :logins, action: :logout

    resources :factories, only: [:index]
    resources :ovens, only: [:index]
    resources :arms, only: [:index]
    resources :runs, only: [:index, :create, :update]
    resources :mould_locations, only: [:index]
    resources :clearcache, only: [:index]


    resources :products, only: [:index,:update]
    get 'products/get_load_details', controller: :products, action: :get_load_details
    get 'products/get_finishing_data', controller: :products, action: :get_finishing_data
    get 'products/get_finish_packaging', controller: :products, action: :get_finish_packaging
    get 'products/get_quality_checklist', controller: :products, action: :get_quality_checklist
    post 'products/set_product_load', controller: :products, action: :set_product_load
    post 'products/set_product_unload', controller: :products, action: :set_product_unload
    post 'products/set_product_finish', controller: :products, action: :set_product_finish
    post 'products/set_product_fault', controller: :products, action: :set_product_fault



    get 'faults/get_fault_types', controller: :faults, action: :get_fault_types
    get 'faults/get_fault_reasons', controller: :faults, action: :get_fault_reasons
    get 'faults/get_fault_categories', controller: :faults, action: :get_fault_categories

  end
end
