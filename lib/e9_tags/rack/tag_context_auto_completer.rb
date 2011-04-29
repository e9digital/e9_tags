module E9Tags::Rack
  class TagContextAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      if env["PATH_INFO"] =~ /^\/autocomplete\/tag\-contexts/
        terms = []

        if @term = Rack::Request.new(env).params['term']

          taggings = ::Tagging.arel_table

          relation = taggings.
                     group(taggings[:context]).
                     where(taggings[:context].matches("#{@term}%")).
                     project(taggings[:context], taggings[:context].count.as('count')).
                     take(DEFAULT_LIMIT).
                     order('context ASC')

          # NOTE this select is stolen from Arel::SelectManager's deprecated to_a method, but since Arel has been re-written
          #      (and even before that) it'd probably be smarter here to avoid arel tables and just use AR and to_json
          #   
          terms = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Tag Context Autocomplete').map do |row| 
            unescaped_context = E9Tags.unescape_context(row['context'])

            { :label => "#{unescaped_context} - #{row['count']}", :value => unescaped_context, :count => row['count'] }
          end
        end

        [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [terms.to_json]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
