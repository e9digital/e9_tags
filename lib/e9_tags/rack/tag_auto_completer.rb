#require File.expand_path('../../../config/environment',  __FILE__) unless defined?(Rails)

module E9Tags::Rack
  class TagAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/tags/
        terms = []
        @params = Rack::Request.new(env).params
        
        if @term = @params['term']
          tags, taggings = ::Tag.arel_table, ::Tagging.arel_table

          relation = tags.join(taggings).on(tags[:id].eq(taggings[:tag_id])).
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
            relation = relation.where(taggings[:context].matches('%__H__').not)
          end

          if @context = @params['context']
            relation = relation.where(taggings[:context].eq(E9Tags.escape_context(@context))) 
          end

          # NOTE this select is stolen from Arel::SelectManager's deprecated to_a method, but since Arel has been re-written
          #      (and even before that) it'd probably be smarter here to avoid arel tables and just use AR and to_json
          #   
          terms = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Tag Autocomplete').each do |row| 
            { :label => "#{row['name']} - #{row['count']}", :value => row['name'], :count => row['count'] }
          end
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [terms.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
