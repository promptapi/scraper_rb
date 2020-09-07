require "test_helper"

class ScraperRbTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ScraperRb::VERSION
  end

  def test_promptapi_token
    skip "PROMPTAPI_TOKEN is exists, skipping test..." if ENV['PROMPTAPI_TOKEN']
    s = ScraperRb.new('https://pypi.org/classifiers/')
    s.get

    refute_nil s.response.fetch(:error)
    assert_equal s.response.fetch(:error), "You need to set PROMPTAPI_TOKEN environment variable"
  end

  def test_scrape_with_basic_params
    skip "PROMPTAPI_TOKEN required, skipping test..." unless ENV['PROMPTAPI_TOKEN']

    s = ScraperRb.new('https://vbyazilim.com', {country: 'EE'})
    s.get
    assert s.response
    assert s.response.fetch(:headers)
    assert s.response.fetch(:data)
    assert s.response.fetch(:url)
  end

  def test_scrape_with_selector_param
    skip "PROMPTAPI_TOKEN required, skipping test..." unless ENV['PROMPTAPI_TOKEN']

    mega_selector = 'body > section.section.main.has-white-background > div > div > div:nth-child(2) > div > div > div > ul > li'
    s = ScraperRb.new('https://vbyazilim.com', {country: 'EE', selector: mega_selector})
    s.get
    assert s.response
    assert s.response.fetch(:headers)
    assert s.response.fetch(:data)
    assert s.response.fetch(:url)
    assert_equal s.response[:data].class, Array
    assert s.response[:data].length > 5
  end
  
end
