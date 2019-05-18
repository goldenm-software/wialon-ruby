# wialon-ruby

wialon-ruby is a Wialon Remote API Wrapper for ruby language.

## Installation

Use the package manager [bundler](https://bundler.io/) to install wialon-ruby.

```bash
gem install wialon
```
OR
```ruby
gem 'wialon'
```
and execute a `bundle install`

## Usage

```ruby
require 'wialon'

debug = false
scheme = 'https'
host = 'hst-api.wialon.com'
port = 0
sid = ''
extra_params = {}

# Initialize Wialon instance
wialon = Wialon.new(debug, scheme, host, port, sid, extra_params)

# Login with API Token
wialon.login("YourTokenHere")

# Logout
wialon.logout
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)