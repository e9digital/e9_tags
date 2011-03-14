require 'active_support/concern'
require 'acts-as-taggable-on'
require 'e9_tags/tagging_extension'

module E9Tags
  autoload :Controller,   'e9_tags/controller'
  autoload :Model,        'e9_tags/model'

  class << self
    def escape_context(c)
      c.downcase.gsub(/\s+/, '__S__').gsub(/-/, '__D__').sub(/\(hidden\)/, '__H__')
    end

    def unescape_context(c)
      c.gsub(/__S__/i, ' ').gsub(/__D__/i, '-').sub(/__H__/, '(hidden)')
    end
  end
end

# Alias ActsAsTaggableOn classes
Tag     = ActsAsTaggableOn::Tag
Tagging = ActsAsTaggableOn::Tagging

ActsAsTaggableOn::Tagging.send(:include, E9Tags::TaggingExtension)
