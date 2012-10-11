require "sinatra"
require "whois"

helpers do
  def expand(expression)
    expression ? `echo #{expression}`.scan(/\S+/) : []
  end
end

get "/" do
  @results = expand(params[:e]).select { |domain| Whois.available?(domain) }
  erb :home
end
