# BadWordDetector

Swear word detector

**Ruleset is not complete. If you want to use it in your project, please edit `lib/config/rules.yaml` or use your own ruleset!**

## Installation

Add this line to your application's Gemfile:

    gem 'bad_word_detector'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bad_word_detector

## Usage

Detects `#uck` , `F|_|__C_K` and other variations of hidden swear words in text.

Usage:

```ruby
finder = BadWordDetector.new
finder.find("What the #uck")
```

it will return BadWord object

Transformation rules is defined in form: 

```ruby
{"#" => {"symbol"=>"f", "weight" => 2}} # weight is optional
```

Or in file conf/rules.yaml 

List of swear words is located in conf/library.yaml

Whitelist of english words in conf/whitelist.yaml

You can also set own rules:

```ruby
finder = BadWordDetector.new rules, library, whitelist
```

Or you can use string filenames for YAML files of same format:

```ruby
finder = BadWordDetector.new 'my_rules.yaml', 'my_library.yaml', 'my_whitelist.yaml'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
