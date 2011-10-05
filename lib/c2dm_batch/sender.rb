module C2dmBatch
  class Sender
    AUTH_URL = 'https://www.google.com/accounts/ClientLogin'
    SEND_URL = 'https://android.apis.google.com/c2dm/send'


    def initialize(email, password, source)
      @email = email
      @password = password
      @source = source

      @hydra = Typhoeus::Hydra.new
      authenticate!
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
      request.body = build_post_body(auth_options)

      headers = {
        'Content-length' => request.body.length.to_s
      }
      request.headers = headers

      @hydra.queue(request)
      @hydra.run
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
      request = create_notification_request(notification)

      @hydra.queue(request)
      @hydra.run
      response = request.response
    end

  private
    def build_post_body(options={})
      post_body = []

      # data attributes need a key in the form of "data.key"...
      data_attributes = options.delete(:data)
      data_attributes.each_pair do |k,v|
        post_body << "data.#{k}=#{CGI::escape(v.to_s)}"
      end if data_attributes

      options.each_pair do |k,v|
        post_body << "#{k}=#{CGI::escape(v.to_s)}"
      end

      post_body.join('&')
    end

    def create_notification_request(notification)
      request = Typhoeus::Request.new(SEND_URL)
      notification[:collapse_key] = 'collapse'
      request.body = build_post_body(notification)

      headers = {
        'Authorization'  => "GoogleLogin auth=#{@auth_token}",
        'Content-type'   => 'application/x-www-form-urlencoded',
        'Content-length' => request.body.length.to_s
      }
      request.headers = headers
      request
    end
  end

end
