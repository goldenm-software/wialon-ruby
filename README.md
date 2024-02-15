# WialonSDK for Ruby
[![Gem Version](https://badge.fury.io/rb/wialon.svg)](https://badge.fury.io/rb/wialon)

## Installation
Use the package manager [bundler](https://bundler.io/) to install wialon-ruby.
```bash
gem install wialon
```
OR
```ruby
gem 'wialon'
```

## Usage
```ruby
## WialonSDK example usage
require 'wialon'
# Initialize Wialon instance
debug = true
scheme = 'https'
host = 'hst-api.wialon.com'
port = 0
session_id = ''
extra_params = {}

sdk = Wialon::Sdk.new(debug, scheme, host, port, session_id, extra_params)

# Login with API Token
token = '' # If you haven't a token, you should use our token generator
           # https://goldenmcorp.com/resources/token-generator

begin
  sdk.login(token)

  parameters = {
    'spec':{
      'itemsType': String,
      'propName': String,
      'propValueMask': String,
      'sortType': String,
      'propType': String,
      'or_logic': TrueClass|FalseClass
    },
    'force': Integer,
    'flags': Integer,
    'from': Integer,
    'to': Integer
  }

  units = sdk.core_search_items(parameters)

  puts "Units: #{units}"

  sdk.logout
rescue SdkException => e
  puts "Sdk related exception #{e}"
rescue Wialon::Error => e
  puts "WialonSdk exception #{e}"
rescue Exception => e
  puts "Ruby exception #{e}"
end
```

## Methods available
For more information, please go to [Wialon Remote API documentation](https://sdk.wialon.com/wiki/en/sidebar/remoteapi/apiref/apiref)

## Work with us!
Feel free to send us an email to [sales@goldenmcorp.com](mailto:sales@goldenmcorp.com)

## Contributing
Merge requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)