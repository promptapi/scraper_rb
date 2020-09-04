require "test_helper"

class ScraperRbTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ScraperRb::VERSION
  end

  def test_environment_variable
    buffer_token = nil
    if ENV['PROMPTAPI_TOKEN']
      buffer_token = ENV['PROMPTAPI_TOKEN']
      ENV.delete('PROMPTAPI_TOKEN')
    end

    result = ScraperRb.scrape(url:"https://example.com")
    refute_nil result.fetch(:error)
    assert_equal result[:error], "You need to set PROMPTAPI_TOKEN environment variable"
    ENV['PROMPTAPI_TOKEN'] = buffer_token if buffer_token
  end

  def test_connection_err
    buffer_token = nil
    buffer_endpoint = nil

    if ENV['PROMPTAPI_TOKEN']
      buffer_token = ENV['PROMPTAPI_TOKEN']
      ENV.delete('PROMPTAPI_TOKEN')
    end
    if ENV['PROMPTAPI_TEST_ENDPOINT']
      buffer_endpoint = ENV['PROMPTAPI_TEST_ENDPOINT']
      ENV.delete('PROMPTAPI_TEST_ENDPOINT')
    end

    ENV['PROMPTAPI_TEST_ENDPOINT'] = "http://no-url-exists.com/"
    ENV['PROMPTAPI_TOKEN'] = "123"

    result = ScraperRb.scrape(url:"https://example.com")

    refute_nil result.fetch(:error)
    assert_equal result[:error], "Connection error"
    
    ENV['PROMPTAPI_TOKEN'] = buffer_token if buffer_token
    ENV['PROMPTAPI_TEST_ENDPOINT'] = buffer_endpoint if buffer_endpoint
  end
end
