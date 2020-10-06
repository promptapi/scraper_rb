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
    def new(url, params={}, headers={}, timeout=10)
      ScraperRb::Scraper.new(url, params, headers, timeout)
    end
  end
  
  class Scraper
    VALID_PARAMS = ['auth_password', 'auth_username', 'cookie', 'country', 'referer', 'selector']

    attr_accessor :options, :response

    def initialize(url, params, extra_headers, timeout)
      params = {} if params == nil
      default_headers = {
        'Accept' => 'application/json', 
        'apikey' => ENV['PROMPTAPI_TOKEN'],
      }
      default_headers.merge!(extra_headers) if extra_headers

      @options = {
        url: ENV['PROMPTAPI_TEST_ENDPOINT'] || 'https://api.promptapi.com/scraper',
        params: {url: url},
        request: {timeout: timeout},
        headers: default_headers,
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

    def save(filename)
      return {error: 'Data is not available'} unless @response[:data]
      save_extension = '.html'
      save_data = @response[:data]
      if @response[:data].class == Array
        save_extension = '.json'
        save_data = JSON.generate(@response[:data])
      end
      file_dirname = File.dirname(filename)
      file_basename = File.basename(filename, save_extension)
      file_savename = "#{file_dirname}/#{file_basename}#{save_extension}"
      begin
        File.open(file_savename, 'w') {|file| file.write(save_data)}
        return {file: file_savename, size: File.size(file_savename)}
      rescue Errno::ENOENT => e
        return {error: "#{e}"}
      end
    end

  end
end
