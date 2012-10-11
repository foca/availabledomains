require "sinatra"
require "whois"

class AvailableDomains < Sinatra::Application
  get "/" do
    @results = query_glob(params[:e])
    pass
  end

  get "/", provides: "html" do
    erb :home
  end

  get "/", provides: "txt" do
    @results.join("\n") << "\n"
  end

  # Check multiple domains for availability.
  #
  # expression - A String with a shell glob expression to expand.
  #
  # Returns an Array of available domain names.
  def query_glob(expression)
    expression = URI.decode(expression.to_s)
    domains = expression.empty? ? [] : `bash -c 'echo #{expression}'`.scan(/\S+/)
    domains.select { |domain| Whois.available?(domain) }
  end
end
