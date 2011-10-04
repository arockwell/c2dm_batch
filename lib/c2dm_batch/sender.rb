module C2dmBatch
  class Sender
    AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
    SEND_URL = 'https://android.apis.google.com/c2dm/send'


    def initialize(email, password, source)
      @email = email
      @password = password
      @source = source
    end

    def authenticate!
      request = Typhoeus::Request.new(AUTH_URL)
      auth_options = {
        'accountType' => 'HOSTED_OR_GOOGLE',
        'service'     => 'ac2dm',
        'Email'       => @email,
        'Passwd'      => @password,
        'source'      => @source,
      }

      post_body = []
      auth_options.each_pair do |k,v|
        post_body << "#{k}=#{CGI::escape(v.to_s)}"
      end
      post_body = post_body.join('&')

      headers = {
        'Content-type'   => 'application/x-www-form-urlencoded',
        'Content-length' => post_body.length.to_s
      }
      request.headers = headers
      request.body = post_body

      # Run the request via Hydra.
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      response = request.response
      auth_token = ""
      if response.success?
        response.body.split("\n").each do |line|
          if line =~ /^Auth=/
            auth_token = line.gsub('Auth=', '')
          end
        end
      end
      @auth_token = auth_token
    end

    def send_notification(notification)
      notification[:collapse_key] = 'collapse'
      post_body = []
      notification.each_pair do |k,v|
        post_body << "#{k}=#{CGI::escape(v.to_s)}"
      end
     
      # data attributes need a key in the form of "data.key"...
      data_attributes = notification.delete(:data)
      data_attributes.each_pair do |k,v|
        post_body << "data.#{k}=#{CGI::escape(v.to_s)}"
      end if data_attributes
      post_body = post_body.join('&')
      puts post_body

      headers = {
        'Authorization'  => "GoogleLogin auth=#{@auth_token}",
        'Content-type'   => 'application/x-www-form-urlencoded',
        'Content-length' => post_body.length.to_s
      }

      request = Typhoeus::Request.new(SEND_URL)
      request.headers = headers
      request.body = post_body
      pp request
      # Run the request via Hydra.
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      response = request.response
      pp response
    end
  end

end
