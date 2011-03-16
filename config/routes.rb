Rails.application.routes.draw do
  # TODO fix the fact that we route to apps, then the apps themselves check those paths
  get '/js/tags' => E9Tags::Rack::TagsJs
  get '/autocomplete/tags' => E9Tags::Rack::TagAutoCompleter
  get '/autocomplete/tag-contexts' => E9Tags::Rack::TagContextAutoCompleter
end
