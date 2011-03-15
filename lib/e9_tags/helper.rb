module E9Tags
  module Helper
    def tag_template(object, tag = "__TAG__", context = "__CONTEXT__", u_context = "__UCONTEXT__")
      class_name = object.class.name.underscore

      tag_html = ''.html_safe.tap do |buffer|
        buffer.safe_concat content_tag(:span, tag)
        buffer.safe_concat content_tag(:a, "Remove", :class => "delete-tag", :title => I18n.t(:delete_tag_link_instructions, :scope => :e9_tags))
      end

      content_tag(:li) do
        ''.html_safe.tap do |html|
          html.safe_concat content_tag(:span, tag_html, :class => "admin-tag")
          html.safe_concat hidden_field_tag("#{class_name}[#{u_context}_tag_list][]", tag, :id => "#{class_name}_#{u_context}_tag_list")
        end
      end
    end

    def humanize_context(context)
      context.gsub(/_/, ' ').titleize
    end

    def tag_list(resource, highlighted_tag = nil, options = {})
      _tag_list(resource.tags(options), highlighted_tag) if resource.respond_to?(:tags)
    end

    def tag_list_with_context(resource, highlighted_tag = nil, options = {})
      if resource.respond_to?(:tagging_contexts)

        # by default, we don't want to show all tags
        options[:show_all] = false if options.blank?

        content_tag(:div, :class => 'tag-lists') do
          ''.html_safe.tap do |html|
            resource.tagging_contexts(options).each do |context|
              str = ''.html_safe
              str.safe_concat content_tag(:div, "#{humanize_context(E9Tags.unescape_context(context))}:", :class => 'heading')
              str.safe_concat _tag_list(resource.tag_list_on(context), highlighted_tag)

              html.safe_concat content_tag(:div, str.html_safe, :class => 'tag-context-list')
            end
          end
        end
      end
    end

    private

    # NOTE this subroutine is kinda useless, should be rewritten to handle both tag list types
    def _tag_list(tags, highlighted_tag = nil)
      content_tag(:div, :class => 'tag-list') do
        tags.each_with_index.map do |tag, index|
          css_class = index == tags.length - 1 ? 'last' : nil
          link_class = 'tag'
          link_class << ' highlight' if highlighted_tag && highlighted_tag == tag
          link_class << ' last' if index == tags.length - 1
          link_to(tag, searches_path(:query => tag), :class => link_class)
        end.join(', ').html_safe
      end
    end
  end
end
