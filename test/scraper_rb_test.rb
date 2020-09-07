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

    s = ScraperRb.new('https://pypi.org/classifiers/', {country: 'EE'})
    s.get

    assert s.response
    assert s.response.fetch(:headers)
    assert s.response.fetch(:data)
    assert s.response.fetch(:url)

    result = s.save('/tmp/test.html')
    assert result.fetch(:file)
    assert result.fetch(:size)
    assert result.fetch(:size) > 300 * 1024
  end

  def test_scrape_with_selector_param
    skip "PROMPTAPI_TOKEN required, skipping test..." unless ENV['PROMPTAPI_TOKEN']

    s = ScraperRb.new('https://pypi.org/classifiers/', {country: 'EE', selector: 'ul li button[data-clipboard-text]'})
    s.get

    assert s.response
    assert s.response.fetch(:headers)
    assert s.response.fetch(:data)
    assert s.response.fetch(:url)
    assert_equal s.response[:data].class, Array
    assert s.response[:data].length > 700
    
    result = s.save('/tmp/test.json')
    assert result.fetch(:file)
    assert result.fetch(:size)
    assert result.fetch(:size) > 512

    error_result = s.save('/tmp-fake/dir/test.json')
    refute_nil error_result.fetch(:error)
    assert_equal error_result[:error], 'No such file or directory @ rb_sysopen - /tmp-fake/dir/test.json'
  end


  def test_scrape_with_timeout
    skip "PROMPTAPI_TOKEN required, skipping test..." unless ENV['PROMPTAPI_TOKEN']

    s = ScraperRb.new('https://pypi.org/classifiers/', {}, timeout=50)
    s.get

    assert s.response
    assert s.response.fetch(:headers)
    assert s.response.fetch(:data)
    assert s.response.fetch(:url)

    s = ScraperRb.new('https://pypi.org/classifiers/', {}, timeout=1)
    s.get

    refute_nil s.response.fetch(:error)
    assert_equal s.response.fetch(:error), "Net::readtimeout with #<tcpsocket:(closed)>"
  end
  
end
