require 'rails'
require 'acts-as-taggable-on'
require 'e9_tags/tagging_extension'

module E9Tags
  autoload :Controller, 'e9_tags/controller'
  autoload :Model,      'e9_tags/model'
  autoload :Helper,     'e9_tags/helper'

  module Rack
    autoload :TagAutoCompleter,         'e9_tags/rack/tag_auto_completer'
    autoload :TagContextAutoCompleter,  'e9_tags/rack/tag_context_auto_completer'
    autoload :TagsJs,                   'e9_tags/rack/tags_js'
  end

  class << self
    def escape_context(c)
      c.downcase.gsub(/\s+/, '__S__').gsub(/-/, '__D__').sub(/\(hidden\)/, '__H__')
    end

    def unescape_context(c)
      c.gsub(/__S__/i, ' ').gsub(/__D__/i, '-').sub(/__H__/, '(hidden)')
    end
  end

  class Engine < ::Rails::Engine
    config.e9_tags = E9Tags

    initializer 'e9_tags.helpers' do
      ActiveSupport.on_load(:action_controller) do
        include E9Tags::Helper
      end
    end

    initializer 'e9_tags.extend_acts_as_taggable_on' do
      ActsAsTaggableOn::Tagging.send(:include, E9Tags::TaggingExtension)
    end
  end
end

# Alias ActsAsTaggableOn classes
Tag     = ActsAsTaggableOn::Tag
Tagging = ActsAsTaggableOn::Tagging
