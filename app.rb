require "sinatra"
require "whois"

helpers do
  def query_glob(expression)
    expression = URI.decode(expression.to_s)
    domains = expression.empty? ? [] : `bash -c 'echo #{expression}'`.scan(/\S+/)
    domains.select { |domain| Whois.available?(domain) }
  end
end

get "/" do
  @results = query_glob(params[:e])
  erb :home
end
