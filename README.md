NOTE: This gem is in the process of being extracted from code used in other projects.  It is untested and a few features haven't been extracted yet, including the form views/javascripts and autocompletion for tags/contexts.

An extension to ActsAsTaggable on which "improves" on custom tagging, or at least makes it more dynamic.

Installation
------------

1.  E9Tags requires jquery and jquery-ui, be sure they're loaded in your pages where the tags form will be rendered.

2.  E9Tags extends ActsAsTaggableOn and requires it.  Run it's generator if you have not.

3.  Run the E9Tags install script to copy over the required JS

        rails g e9_tags:install

4.  Then make sure it is loaded, how you do that doesn't matter, e.g.

        <%= javascript_include_tag 'e9_tags' %>

5.  Create an initializer for that sets up the taggable models and their controllers.  This gives the models the tag
    associations and methods and prepares their controller to handle the otherwise unexpected tag params.

        require 'e9_tags'
        require 'contacts_controller'
        require 'contact'

        E9Tags.controllers << ContactsController
        E9Tags.models << Contact

6.  Render the tags form partial in whatever model forms require it.  

        = render 'e9_tags/form', :f => f

    If you pass a context, it will be locked and no longer possible to change/add the contexts on the form (and as 
    a side effect, the tags autocompletion will be restricted to that context).

        = render 'e9_tags/form', :f => f, :context => :users

    Finally if you pass a 2nd arg to :context you can set a tag context to be "private" (default is false).  In this
    case the tag context will be locked as private (typically suffixed with *), meaning that the tags will not be
    publicly searchable/visible.  This is useful for organizational tags tags, say if you wanted to arbitrarily
    group records, or create a custom search based on a tag context.

        = render 'e9_tags/form', :f => f, :context => [:users, true]

