Rails.application.routes.draw do
  post '/webhook' => 'linebot#webhook'
  root to: 'linebot#index'
end
