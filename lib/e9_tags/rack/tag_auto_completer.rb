module E9Tags::Rack
  class TagAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/tags/
        terms = []
        @params = Rack::Request.new(env).params
        
        if @term = @params['term']
          tags, taggings = Table(:tags), Table(:taggings)

          terms = tags.join(taggings).on(tags[:id].eq(taggings[:tag_id])).
                       where(tags[:name].matches("#{@term}%")).
                       group(tags[:id]).
                       take(@params['limit'] ? @params['limit'].to_i : DEFAULT_LIMIT).
                       project(tags[:name], tags[:name].count.as('count')).
                       #having('count > 0'). # having count > 0 is unnecessary because of the join type
                       order('name ASC')

          # NOTE realized after the fact that the "hidden" concept is probably unnecessary, as the
          # "context" in public side tag completion is *always* tags and that by itself will filter out
          # hidden tags.
          #
          # TODO remove this concept, and remove it from the tags.js where this param is passed
          #
          if @params['hidden'] != '1'
            terms = terms.where(taggings[:context].matches('%__H__').not)
          end

          if @context = @params['context']
            terms = terms.where(taggings[:context].eq(Taggable.escape_context(@context))) 
          end

          terms = terms.map {|tag| { :label => "#{tag.tuple[0]} - #{tag.tuple[1]}", :value => tag.tuple[0], :count => tag.tuple[1] } }
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [terms.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
