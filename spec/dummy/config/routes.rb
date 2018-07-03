Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :posts do
    act_as_group
  end

  resources :default_posts, controller: :posts do
    act_as_group
  end

  resources :only_posts, controller: :posts do
    act_as_group only: %i[create destroy]
  end

  resources :except_posts, controller: :posts do
    act_as_group except: %i[destroy]
  end
end
