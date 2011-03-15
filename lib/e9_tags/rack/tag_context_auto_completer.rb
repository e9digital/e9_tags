module E9Tags::Rack
  class TagContextAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/tag\-contexts/
        terms = []

        if @term = Rack::Request.new(env).params['term']

          taggings = Table(:taggings)
          terms = taggings.group(taggings[:context]).
                           where(taggings[:context].matches("#{@term}%")).
                           project(taggings[:context], taggings[:context].count.as('count')).
                           take(DEFAULT_LIMIT).
                           order('context ASC')

          # NOTE arel arrays don't support map!
          terms = terms.map do |tagging| 
            unescaped_context = Taggable.unescape_context(tagging.tuple[0])
            { :label => "#{unescaped_context} - #{tagging.tuple[1]}", :value => unescaped_context, :count => tagging.tuple[1] }
          end
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [terms.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
