![Ruby](https://img.shields.io/badge/ruby-2.7.0-green.svg)
[![Gem Version](https://badge.fury.io/rb/scraper_rb.svg)](https://badge.fury.io/rb/scraper_rb)
[![Build Status](https://travis-ci.org/promptapi/scraper_rb.svg?branch=main)](https://travis-ci.org/promptapi/scraper_rb)

# Prompt API - Scraper API - Ruby Package

`scraper_rb` is a simple python wrapper for [scraper-api][scraper-api].

## Requirements

1. You need to signup for [Prompt API][promptapi-signup]
1. You need to subscribe [bincheck-api][bincheck-api], test drive is **free!!!**
1. You need to set `PROMPTAPI_TOKEN` environment variable after subscription.

then;

```bash
$ gem install scraper_rb
```

or; install from GitHub:

```bash
$ gem install scraper_rb --version "0.1.0" --source "https://rubygems.pkg.github.com/promptapi"
```

---

## Example Usage

Basic scraper:

```ruby
require "scraper_rb"

s = ScraperRb.new('https://pypi.org/classifiers/') # no params
s.get
s.response
# {
#     :headers=>{:"Content-Length"=>...}, 
#     :url=>"https://pypi.org/classifiers/",
#     :data=>"<!DOCTYPE html>\n<html> ...",
# }

s.response[:headers]     # => return response headers
s.response[:data]        # => return scraped html
s.save('/tmp/data.html') # => {:file=>"/tmp/data.html", :size=>321322}

# or

save_result = s.save('/tmp/data.html')
puts save_result[:error] if save_result.key?(:error) # we have a file error
```

You can add url parameters for extra operations. Valid parameters are:

- `auth_password`: for HTTP Realm auth password
- `auth_username`: for HTTP Realm auth username
- `cookie`: URL Encoded cookie header.
- `country`: 2 character country code. If you wish to scrape from an IP address of a specific country.
- `referer`: HTTP referer header
- `selector`: CSS style selector path such as `a.btn div li`. If `selector`
  is enabled, returning result will be collection of data and saved file
  will be in `.json` format.

Here is an example with using url parameters and `selector`:

```ruby
require "scraper_rb"

params = {country: 'EE', selector: 'ul li button[data-clipboard-text]'}
s = ScraperRb.new('https://pypi.org/classifiers/', params)
s.get
s.response[:headers]       # => return response headers
s.response[:data]          # => return an array, collection of given selector
s.response[:data].length   # => 734 
s.save('/tmp/test.json')   # => {:file=>"/tmp/test.json", :size=>174449}

# or

save_result = s.save('/tmp/test.json')
puts save_result[:error] if save_result.key?(:error) # we have a file error
```

Default **timeout** value is set to `10` seconds. You can change this while
initializing the instance:

```ruby
s = ScraperRb.new('https://pypi.org/classifiers/', {}, timeout=50) 
# => 50 seconds timeout w/o params

s = ScraperRb.new('https://pypi.org/classifiers/', {country: 'EE'}, timeout=50) 
# => 50 seconds timeout
```

---

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org][rubygems]

```bash
$ rake -T

rake build            # Build bin_checker_rb-X.X.X.gem into the pkg directory
rake clean            # Remove any temporary products
rake clobber          # Remove any generated files
rake install          # Build and install bin_checker_rb-X.X.X.gem into system gems
rake install:local    # Build and install bin_checker_rb-X.X.X.gem into system gems without network access
rake release[remote]  # Create tag v0.0.0 and build and push bin_checker_rb-X.X.X.gem to rubygems.org
rake test             # Run tests
```

- If you have `PROMPTAPI_TOKEN` you’ll have real http request based tests available.
- Set `RUBY_DEVELOPMENT` to `1` for more verbose test results

---

## License

This project is licensed under MIT

---

## Contributer(s)

* [Prompt API](https://github.com/promptapi) - Creator, maintainer

---

## Contribute

Bug reports and pull requests are welcome on GitHub:

1. `fork` (https://github.com/promptapi/scraper_rb/fork)
1. Create your `branch` (`git checkout -b my-feature`)
1. `commit` yours (`git commit -am 'Add awesome features...'`)
1. `push` your `branch` (`git push origin my-feature`)
1. Than create a new **Pull Request**!

This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct][coc].

---

[promptapi-signup]: https://promptapi.com/#signup-form
[scraper-api]:      https://promptapi.com/marketplace/description/scraper-api
[rubygems]:         https://rubygems.org
[coc]:              https://github.com/promptapi/scraper_rb/blob/main/CODE_OF_CONDUCT.md
