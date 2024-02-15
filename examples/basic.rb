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
