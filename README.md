NOTE: This gem is in the process of being extracted from code used in other projects.  It is untested and a few features haven't been extracted yet, including the form views/javascripts and autocompletion for tags/contexts.

An extension to ActsAsTaggable on which "improves" on custom tagging, or at least makes it more dynamic.

Installation
------------

1.) E9Tags requires jquery and jquery-ui, be sure they're loaded in your pages where the tags form will be rendered.

2.) E9Tags extends ActsAsTaggableOn and requires it.  Run it's generator if you have not.

3.) Run the E9Tags install script to copy over the required JS

  rails g e9_tags:install

4 .) Then make sure it is loaded, how you do that doesn't matter, e.g.
  <%= javascript_include_tag 'e9_tags' %>
