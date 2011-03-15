require 'rails/generators/named_base'

module E9Tags
  module Generators
    class InstallGenerator < Rails::Generator::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      def install_javascript
        copy_file 'tags.js', 'public/javascripts/tags.js'
      end
    end
  end
end
