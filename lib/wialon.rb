class Wialon
  require 'json'
  require 'net/http'
  require 'uri'

  # Variables
  attr_accessor :sid, :base_api_url, :default_params, :uid, :host, :scheme, :debug

  # Class constructor
  def initialize(debug = false, scheme = 'https', host = 'hst-api.wialon.com', port = 0, sid = '', extra_params = {})
    self.debug = debug
    self.sid = ''
    self.scheme = scheme
    self.default_params = {}
    self.default_params.replace(extra_params)
    self.host = host
    self.base_api_url = "#{scheme}://#{host}#{((port > 0) ? ":" + port.to_s : "")}/wialon/ajax.html?"
    self.uid = ''
  end

  def get_address(lat, lon, flags = 1255211008)
    if self.debug
      puts "URL: #{'https://geocode-maps.wialon.com/' + self.host + '/gis_geocode?coords=[' + JSON.generate({"lon": lon,"lat": lat}) + ']&flags=' + flags.to_s + '&uid=' + self.uid.to_s}"
    end
    uri = URI.parse('https://geocode-maps.wialon.com/' + self.host + '/gis_geocode?coords=[' + JSON.generate({"lon": lon,"lat": lat}) + ']&flags=' + flags.to_s + '&uid=' + self.uid.to_s)
    request = Net::HTTP::Post.new(uri)
    req_options = { use_ssl: (uri.scheme == "https") }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return JSON.parse(response.body)[0]
  end

  def get_coordinates(string) 
    string = string.split(" ").join(" ")
    from  = "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž"
    to = "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
    string = string.tr(from,to)

    uri = URI.parse('https://search-maps.wialon.com/' + self.host + '/gis_searchintelli?phrase=' + string + '&count=1&indexFrom=0&uid=' + self.uid.to_s)
    request = Net::HTTP::Post.new(uri)
    req_options = { use_ssl: (uri.scheme == "https") }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    return JSON.parse(response.body) 
  end 

  def call_without_svc_parse(action, args)
    # Set local variable with base url
    url = self.base_api_url

    # Set params
    params = {'svc': action.to_s, 'params': JSON.generate(args), 'sid': self.sid}
    
    # Replacing global params with local params
    all_params = self.default_params.replace(params)

    if self.debug
      puts "========="
      puts "Query URL: #{url} - Params: #{all_params}"
      puts "========="
      puts "#{url}&svc=#{action.to_s}&params=#{JSON.generate(args)}&sid=#{self.sid}"
      puts "========="
    end

    uri = URI.parse(url)
    
    # Curl request
    request = Net::HTTP::Post.new(uri)

    request.set_form_data(
      "svc" => action.to_s,
      "params" => JSON.generate(args),
      "sid" => self.sid
    )

    req_options = { use_ssl: (uri.scheme == "https") }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response = JSON.parse(response.body)

    return response
  end

  # RemoteAPI request performer
  # action: RemoteAPI command name
  # args: JSON string with request parameters
  def call(action, args)
    # Set local variable with base url
    url = self.base_api_url

    # Set params
    params = {'svc': action.to_s.sub('_', '/'), 'params': JSON.generate(args), 'sid': self.sid}
    
    # Replacing global params with local params
    all_params = self.default_params.replace(params)

    if self.debug
      puts "========="
      puts "Query URL: #{url} - Params: #{all_params}"
      puts "========="
      puts "#{url}&svc=#{action.to_s.sub('_', '/')}&params=#{JSON.generate(args)}&sid=#{self.sid}"
      puts "========="
    end

    uri = URI.parse(url)
    
    # Curl request
    request = Net::HTTP::Post.new(uri)

    request.set_form_data(
      "svc" => action.to_s.sub('_', '/'),
      "params" => JSON.generate(args),
      "sid" => self.sid
    )

    req_options = { use_ssl: (uri.scheme == "https") }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response = JSON.parse(response.body, symbolize_names: true)

    if response.class == Hash
      if !response[:error].nil?
        return {
          status: 400,
          reason: parse_errors(response[:error]),
          result: response
        }
      end
    end

    return {
      status: 200,
      result: response
    }
  end

  def login(token)
    result = self.token_login({token: token})
    if !result[:result][:eid].nil?
      self.sid = result[:result][:eid]
    end

    begin
      if !result[:result][:user][:id].nil?
        self.uid = result[:result][:user][:id]
      end
    rescue Exception => e
      if self.debug
        puts "Error in login: #{e}"
      end
    end
    return result
  end

  def logout
    result = self.core_logout()
    if result.empty? && result[:result][:error] == 0
      self.sid = ""
    end
    return result
  end

  # Unknonwn methods handler
  def method_missing(name, *args)
    if self.debug
      puts "Query method: #{name}"
    end

    return self.call(name, ((args.count === 0) ? '{}' : args[0]))
  end

  private 
    def parse_errors(code)
      errors = {
        '1' => "Invalid session",
        '2' => "Invalid service name",
        '3' => "Invalid result",
        '4' => "Invalid input",
        '5' => "Error performing request",
        '6' => "Unknown error",
        '7' => "Access denied",
        '8' => "Invalid user name or password",
        '9' => "Authorization server is unavailable",
        '10' => "Reached limit of concurrent requests",
        '11' => "Password reset error",
        '14' => "Billing error",
        '1001' => "No messages for selected interval",
        '1002' => "Item with such unique property already exists or Item cannot be created according to billing restrictions",
        '1003' => "Only one request is allowed at the moment",
        '1004' => "Limit of messages has been exceeded",
        '1005' => "Execution time has exceeded the limit",
        '1006' => "Exceeding the limit of attempts to enter a two-factor authorization code",
        '1011' => "Your IP has changed or session has expired",
        '2014' => "Selected user is a creator for some system objects, thus this user cannot be bound to a new account",
        '2015' => "Sensor deleting is forbidden because of using in another sensor or advanced properties of the unit"
      }

      if errors[code.to_s].nil?
        return "Unknown error"
      else
        return errors[code.to_s]
      end
    end
    # SID setter
    def set_sid(sid)
      self.sid = sid
    end

    # SID getter
    def get_sid
      return self.sid
    end

    # Update extra parameters
    def update_extra_params(params)
      self.default_params.replace(params)
    end
end