## WialonSDK class
module Wialon
  class Sdk
    require 'json'
    require 'net/http'
    require 'uri'

    attr_accessor :session_id, :base_url, :default_params, :user_id, :host, :is_development

    def initialize(is_development = false, scheme = 'https', host = 'hst-api.wialon.com', port = 0, session_id = '', extra_params = {})
      self.is_development = is_development
      self.session_id = session_id
      self.host = host

      self.default_params = {}
      self.default_params.replace(extra_params)

      if port < 0
        raise SdkException.new('Invalid port, must be greater than 0')
      elsif port.to_i > 0
        self.base_url = "#{scheme}://#{host}:#{port}"
      else
        self.base_url = "#{scheme}://#{host}"
      end

      self.base_url += '/wialon/ajax.html?'
      self.user_id = 0
    end

    def reverse_geocoding(latitude, longitude, flags=1255211008)
      coordinates = JSON.generates({latitude: latitude, longitude: longitude})
      url = "https://geocode-maps.wialon.com/#{self.host}/gis_geocode?coords=[#{coordinates}]&flags=#{flags}&uid=#{self.user_id}"

      if self.is_development
        self.debug_printer("Method: Reverse geocoding service\nURL: #{url}")
      end

      begin
        uri = URI.parse(url)
      rescue Exception => e
        raise SdkException.new("Internal error: #{e}")
      end

      request = Net::HTTP::Post.new(uri)

      begin
        response = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: uri.scheme == 'https' }) do |http|
          http.request(request)
        end
      rescue Exception => e
        raise SdkException.new("Internal error: #{e}")
      end

      begin
        response = JSON.parse(response.body)
      rescue Exception => e
        raise SdkException.new("Internal error: #{e}")
      end

      return response[0]
    end

    def login(token)
      result = self.token_login({ token: token })

      self.user_id = result['user']['id']
      self.session_id = result['eid']

      return result
    end

    def logout
      self.core_logout
      return nil
    end

    def set_session_id(session_id)
      self.session_id = session_id
    end

    def get_session_id
      return self.session_id
    end

    protected
      def call(method_name, args)
        svc = ''
        if method_name.to_s == 'unit_group_update_units'
          svc = 'unit_group/update_units'
        else
          svc = method_name.to_s.sub('_', '/')
        end

        begin
          parameters = JSON.generate(args)
        rescue Exception => e
          raise SdkException.new("Internal error: #{e}")
        end

        parameters = {
          svc: svc,
          params: parameters,
          sid: self.session_id
        }

        url = "#{self.base_url}svc=#{parameters[:svc]}&params=#{parameters[:params]}&sid=#{parameters[:sid]}"
        if self.is_development
          self.debug_printer("Method: #{svc}\nParameters: #{parameters}\nURL: #{url}")
        end

        begin
          uri = URI.parse(url)
        rescue Exception => e
          raise SdkException.new("Internal error: #{e}")
        end

        request = Net::HTTP::Post.new(uri)
        request.set_form_data(
          'svc' => parameters[:svc],
          'params' => parameters[:params],
          'sid' => parameters[:sid]
        )

        begin
          response = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: uri.scheme == 'https' }) do |http|
            http.request(request)
          end
        rescue Exception => e
          raise SdkException.new("Internal error: #{e}")
        end

        begin
          response = JSON.parse(response.body)
        rescue Exception => e
          raise SdkException.new("Internal error: #{e}")
        end

        if response.class == Hash
          if !response['error'].nil?
            if response['error'] != 0
              raise Wialon::Error.new(response['error'].to_i, (response['reason'].nil? ? '' : response['reason']))
            end
          end
        end

        return response
      end

      def debug_printer(message)
        puts "*******" * 10
        puts "#{message}"
        puts "*******" * 10
      end

      def method_missing(method_name, *args)
        return self.call(method_name, args.count == 0 ? {} : args[0])
      end
  end

  class Error < Exception
    def initialize(code, details = '')
      _errors = {
        -1 => 'Unhandled error code',
        1 => 'Invalid session',
        2 => 'Invalid service name',
        3 => 'Invalid result',
        4 => 'Invalid input',
        5 => 'Error performing request',
        6 => 'Unknown error',
        7 => 'Access denied',
        8 => 'Invalid user name or password',
        9 => 'Authorization server is unavailable',
        10 => 'Reached limit of concurrent requests',
        11 => 'Password reset error',
        14 => 'Billing error',
        1001 => 'No messages for selected interval',
        1002 => 'Item with such unique property already exists or Item cannot be created according to billing restrictions',
        1003 => 'Only one request is allowed at the moment',
        1004 => 'Limit of messages has been exceeded',
        1005 => 'Execution time has exceeded the limit',
        1006 => 'Exceeding the limit of attempts to enter a two-factor authorization code',
        1011 => 'Your IP has changed or session has expired',
        2014 => 'Selected user is a creator for some system objects, thus this user cannot be bound to a new account',
        2015 => 'Sensor deleting is forbidden because of using in another sensor or advanced properties of the unit'
      }

      @message = ''
      if _errors[code].nil?
        @message = "#{_errors[-1]}"
      else
        @message = "#{_errors[code]}"
      end

      if details.length > 0
        @message += " - #{details}"
      end

      @code = code
      super("WialonError(code: #{@code}, reason: #{@message})")
    end
  end
end

class SdkException < Exception
  def initialize(message = '')
    @message = message
    super("SdkException(#{@message})")
  end
end