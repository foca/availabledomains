require "sinatra"
require "whois"

helpers do
  def expand(expression)
    Array(expression && `bash -c 'echo #{expression}'`.scan(/\S+/))
  end
end

get "/" do
  expression = URI.decode(params[:e])
  @results = expand(expression).select { |domain| Whois.available?(domain) }
  erb :home
end
