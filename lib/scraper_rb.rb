require "scraper_rb/version"
require 'faraday'
require 'json'

module ScraperRb
  class Error < StandardError; end

  # <3 mislav
  # https://mislav.net/2011/07/faraday-advanced-http/
  class CustomURLMiddleware
    def initialize(app, options = {})
      @app = app
      @options = options
    end

    def call(env)
      $stderr.puts "-> #{env[:url]}"
      @app.call(env)
    end
  end
  
  class << self
    def new(url, params={})
      puts "params: #{params}" if ENV['RUBY_DEVELOPMENT']
      ScraperRb::Scraper.new(url, params)
    end
  end
  
  class Scraper
    VALID_PARAMS = ['auth_password', 'auth_username', 'cookie', 'country', 'referer', 'selector']

    attr_accessor :options, :response

    def initialize(url, params=nil, timeout=10)
      @options = {
        url: ENV['PROMPTAPI_TEST_ENDPOINT'] || 'https://api.promptapi.com/scraper',
        params: {url: url},
        request: {timeout: timeout},
        headers: {'Accept' => 'application/json', 'apikey' => ENV['PROMPTAPI_TOKEN']},
      }
      params.each do |key, value|
        @options[:params][key] = value if VALID_PARAMS.map(&:to_sym).include?(key)
      end
      
      @response = {}
    end
    
    def parse(body)
      begin
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError
        {error: "JSON decoding error"}
      end
    end
  
    def get
      unless @options[:headers]['apikey']
        @response = {error: "You need to set PROMPTAPI_TOKEN environment variable"}
        return
      end

      conn = Faraday.new(@options) do |c|
        c.use Faraday::Response::RaiseError
        c.use CustomURLMiddleware if ENV['RUBY_DEVELOPMENT']
      end

      begin
        response = conn.get
        @response = parse(response.body)
        @response[:data] = @response[:"data-selector"] if @response.key?(:"data-selector")
      rescue Faraday::ConnectionFailed
        @response = {error: "Connection error"}
      rescue Faraday::TimeoutError => e
        @response = {error: e.message.capitalize}
      rescue Faraday::ClientError => e
        @response = {error: parse(e.response[:body])}
      rescue Faraday::ServerError => e
        @response = {error: e.message.capitalize}
      end
    end

  end

end
