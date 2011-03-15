class TagsJs
  def self.call(env)
    @params = Rack::Request.new(env).params

    tags = Tagging.joins(:tag).order('tags.name').group_by(&:context).to_json

    js = "window.e9=window.e9||{};window.e9.tags=#{tags};"

    [200, {"Content-Type" => "text/javascript", "Cache-Control" => "max-age=3600, must-revalidate"}, [js]]
  end
end
