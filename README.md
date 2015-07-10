# GpsdClient

A simple GPSd client intended for use on the Raspberry Pi.

Actually only implements new(options = {}), start(), stop(), and get_position() which are just a few but very simple methods.
(See Usage)


* Next days will fix some non fatal bugs. (like actually closing the socket on stop())
* Next version will implement fix_status(), time(), speed() and altitude().
* Next Next will clean-up the code.
* The Next after the Next-Next will add some documentation.

Stay Tuned!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gpsd_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gpsd_client

## Usage

```ruby
# you can specify the host and port for remotes machines or different ports
# ...or not. (defaults to "localhost", 2947)

# gpsd = GpsdClient::Gpsd.new({:host => "nameofthehost", :port => 2947})
gpsd = GpsdClient::Gpsd.new()
gpsd.start()

if gpsd.started?
  pos = gpsd.get_position
  # => {:lat => xx, :lon => xx}
end

# To stop polling the daemon
gpsd.stop()
# Actually Gpsd.stop() doesn't close the connection socket (to be fixed)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/rccursach/gpsd_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
