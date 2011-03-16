module E9Tags::Rack
  class TagsJs
    def self.call(env)
      if env["PATH_INFO"] =~ /^\/js\/tags/
        @params = Rack::Request.new(env).params

        tags = ::Tagging.joins(:tag).order('tags.name').group_by(&:context).to_json

        js = "window.e9=window.e9||{};window.e9.tags=#{tags};"

        [200, {"Content-Type" => "text/javascript", "Cache-Control" => "max-age=3600, must-revalidate"}, [js]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
