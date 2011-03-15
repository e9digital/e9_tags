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

  #
  # Controllers that are prepared to handle taggable models
  #
  mattr_accessor :controllers
  @@controllers = []

  #
  # Models that are taggable
  #
  mattr_accessor :models
  @@models = []

  def E9Tags.escape_context(c)
    c.downcase.gsub(/\s+/, '__S__').gsub(/-/, '__D__').sub(/\(hidden\)/, '__H__')
  end

  def E9Tags.unescape_context(c)
    c.gsub(/__S__/i, ' ').gsub(/__D__/i, '-').sub(/__H__/, '(hidden)')
  end

  def E9Tags.setup!
    ActsAsTaggableOn::Tagging.send(:include, E9Tags::TaggingExtension)

    E9Tags.models.each {|m| m.send(:include, E9Tags::Model) }
    E9Tags.controllers.each {|m| m.send(:include, E9Tags::Controller) }
  end

  class Engine < ::Rails::Engine
    config.e9_tags = E9Tags

    config.to_prepare { E9Tags.setup! }

    initializer 'e9_tags.include_helper' do
      ActiveSupport.on_load(:action_view) do
        include E9Tags::Helper
      end
    end
  end
end

# Alias ActsAsTaggableOn classes
Tag     = ActsAsTaggableOn::Tag
Tagging = ActsAsTaggableOn::Tagging
