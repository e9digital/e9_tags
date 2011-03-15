Rails.application.routes.draw do
  get '/js/tags' => E9Tags::Rack::TagsJs, :defaults => { :format => 'js' }
  get '/autocomplete/tags' => E9Tags::Rack::TagAutoCompleter
  get '/autocomplete/tag-contexts' => E9Tags::Rack::TagContextAutoCompleter
end
