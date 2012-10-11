require "sinatra"
require "whois"

helpers do
  def expand(expression)
    expression.empty? ? [] : `bash -c 'echo #{expression}'`.scan(/\S+/)
  end
end

get "/" do
  expression = URI.decode(params[:e].to_s)
  @results = expand(expression).select { |domain| Whois.available?(domain) }
  erb :home
end
