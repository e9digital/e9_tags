module E9Tags
  module Model
    extend ActiveSupport::Concern

    #
    # It should be noted that our usage of tag contexts is apparently 
    # incongruent with acts_as_taggable_on's intentions.  It goes to lengths 
    # to write class methods for each context with the apparent intention that 
    # these be used separately, whereas we needed contexts to be more dynamic 
    # (all contexts but "tags" are user defined).
    #
    # The gem provides custom contexts but they're not very well supported
    # and somewhat broken (see #tagging_contexts below).
    #
    # Because of the way AATO expects contexts to be used, it makes some
    # assumptions, and writes a bunch of helper methods to the class for each.
    # These are useless to us really and only serve to add some confusion to
    # the scope.  E.g. for acts_as_taggable_on :tags (the default), the 
    # following methods are created:
    #
    # tag_taggings (has_many)
    # tags (has_many)
    # tags_list
    # tags_list=
    # all_tags_list
    #
    # It's important to note that these methods all only deal with the "tags"
    # context and won't return any tag which does not have it.
    #
    # The actual associations on the taggable record are "taggings" and 
    # "base_tags", which ignores context, returning all tags.
    #

    def has_tags?
      !base_tags.empty?
    end

    # Override ActsAsTaggableOn's broken handling of tagging_contexts.
    #
    # This method by default reads:
    #
    # def tagging_contexts
    #   custom_contexts + self.class.tag_types.map(&:to_s)
    # end
    #
    # ...where custom_contexts is an non-persistent instance variable
    # on the record and tag_types are the tagging contexts defined
    # on the class itself, e.g. acts_as_taggable_on :some_context.
    #
    # This means that proper custom contexts aren't reflected in 
    # tagging_contexts on retrieved records. 
    #
    # For this reason we override/monkeypatch a few methods
    # after including acts_as_taggable, making them more useful.  The concept
    # of "hidden" tags is also added, with the default "tagging_contexts" association
    # overridden to return only "visible" tags.  "Hidden" tags are denoted
    # by having a context ending in __H__, a contrivance created in the javascript
    # that handles adding/reading tags.  
    #
    # Additionally contexts are further escaped by subsituting dashes and spaces with
    # __D__ and __S__, respectively.  This allows for those character in custom contexts,
    # which is otherwise impossible due to the way that AATO caches contexts on the
    # taggable object by dynamically writing context-named instance variables.
    #

    #
    # this won't take unless the record is saved successfully
    #
    def clear_all_tags
      tagging_contexts.each {|context| set_tag_list_on(context, '') }
    end

    def tag_lists=(hash)
      self.clear_all_tags
      hash.each do |context, tags|
        c = context.to_s.sub(/_tag_list$/, '')
        c = E9Tags.escape_context(c)

        self.set_tag_list_on(c, tags)
      end
    end

    included do
      acts_as_taggable

      def self.tagged_with(tags, options = {})
        retv = super

        # if :show_all is true, just return super with no modification
        #
        if !options[:show_all] && retv.joins_values.present? && retv.to_sql =~ /JOIN taggings (\S+)/
          #
          # otherwise we'll show hidden OR visible tags based on whether :show_hidden was passed
          #
          retv = retv.where(
            %Q[#{$1}.context #{options[:show_hidden] ? '' : ' NOT '} like '%__H__']
          )
        end

        retv
      end

      # TODO Tagged_with unfortunately does not handle context-only searches.  Rewriting it to do so would save this unnecessary subquery
      scope :tagged_with_context, lambda {|context|
        where(:id => select(Arel::Distinct.new(arel_table[:id])).joins(:taggings).where(Tagging.arel_table[:context].eq(Taggable.escape_context(context))).map(&:id))
      }

      def filtered_taggings(*args)
        options = args.extract_options!

        retv = taggings(*args << options.slice!(:show_all, :show_hidden))

        if !options[:show_all]
          retv = retv.where(
            %Q[taggings.context #{options[:show_hidden] ? '' : ' NOT '} like '%__H__']
          )
        end

        retv
      end

      def tags(options = {})
        filtered_taggings(options).map {|tagging| tagging.tag.name if tagging }.compact.uniq
      end

      #
      # rewrite tagging_contexts as mentioned above
      #
      # NOTE unlike tags & taggings, tagging_contexts returns all contexts
      #      This is crucial because AATO uses tagging_contexts internally
      #      and it needs to behave like the default method
      #
      def tagging_contexts(options = {})

        # NOTE this takes options but it only affects taggings.
        #      if there are custom_contexts that are hidden they will
        #      be returned
        options[:show_all] = true if options.blank?

        (custom_contexts + filtered_taggings(options).map(&:context) + self.class.tag_types.map(&:to_s)).uniq
      end
    end
  end
end
