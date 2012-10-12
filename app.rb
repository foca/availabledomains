require "sinatra"
require "whois"
require "dalli"

class AvailableDomains < Sinatra::Application
  configure :production do
    require "memcachier"
  end

  set :cache, Dalli::Client.new

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
    domains.select { |domain| available?(domain) }
  end

  # Check if a domain is available. The result is cached.
  #
  # domain - A String with a domain name.
  #
  # Returns true|false.
  def available?(domain)
    res = self.class.cache.get(domain)
    if res.nil?
      res = Whois.available?(domain)
      self.class.cache.set(domain, res, 60 * 60 * 24) # one day
    end
    res
  end
end
