module E9Tags
  module Controller
    extend ActiveSupport::Concern

    included do
      prepend_before_filter :extract_tag_lists_from_params, :only => [:create, :update]
    end
    
    def extract_tag_lists_from_params 
      params[resource_instance_name] ||= {}

      list_keys = params[resource_instance_name].keys.select {|k| k.to_s =~ /_tag_list$/ }
      tags = params[resource_instance_name].slice(*list_keys)

      params[resource_instance_name].except!(*list_keys)
      params[resource_instance_name][:tag_lists] = tags
    end

    protected :extract_tag_lists_from_params
  end
end
