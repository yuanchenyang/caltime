# Caltime
Hate the CalTime web interface? Enjoy doing as many things as possible with command line scripts? This gem is for you.

## Installation

This project is not yet on rubygems, so you will need to clone the repo and build+install it yourself:
```
git clone https://github.com/nherson/caltime && cd caltime
gem build caltime.gemspec
gem install ./caltime.gemspec-0.0.1.gem
```

When it makes it to rubygems you will be able to install it with a simple `gem install caltime`


## Usage

### Library

```ruby
require 'caltime'
# Create a session instance
c = Caltime.new

# authenticate yourself, will prompt for CalNet ID and passphrase
c.authenticate

# Record a punch
c.punch

# Print your timecard
puts c.timecard

# Returns true if you are currently punched in
c.punched_in?

# Returns true if you are currently punched out
c.punched_out?
```

### Command line tool

Coming soon :)


