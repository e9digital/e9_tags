require 'rails'
require 'acts-as-taggable-on'
require 'e9_tags/tagging_extension'
require 'e9_tags/rails_extensions'

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

  ESCAPED_DASH             = '__d__'
  ESCAPED_DASH_REGEX       = Regexp.new(Regexp.escape(ESCAPED_DASH), true)

  ESCAPED_SPACE            = '__s__'
  ESCAPED_SPACE_REGEX      = Regexp.new(Regexp.escape(ESCAPED_SPACE), true)

  ESCAPED_PRIVATE          = '__h__'
  ESCAPED_PRIVATE_REGEX    = Regexp.new(Regexp.escape(ESCAPED_PRIVATE), true)

  PRIVATE_TAG_SUFFIX       = '*'
  PRIVATE_TAG_SUFFIX_REGEX = Regexp.new(Regexp.escape(PRIVATE_TAG_SUFFIX), true)

  def E9Tags.escape_context(context)
    context.to_s.strip.
            downcase.
            gsub(/\s+/, ESCAPED_SPACE).
            gsub(/-/, ESCAPED_DASH).
            sub(PRIVATE_TAG_SUFFIX_REGEX, ESCAPED_PRIVATE)
  end

  def E9Tags.unescape_context(context)
    context.to_s.strip.
            gsub(ESCAPED_SPACE_REGEX, ' ').
            gsub(ESCAPED_DASH_REGEX, '-').
            sub(ESCAPED_PRIVATE_REGEX, PRIVATE_TAG_SUFFIX).
            downcase.
            titleize
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
