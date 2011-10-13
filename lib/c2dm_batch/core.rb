module C2dmBatch
  @auth_url = 'https://www.google.com/accounts/ClientLogin'
  @send_url = 'https://android.apis.google.com/c2dm/send'

  @email = nil
  @password = nil 
  @source = nil

  @hydra = Typhoeus::Hydra.new
  @logger = Logger.new(STDOUT)

  class << self
    attr_accessor :auth_url, :send_url, :email, :password, :source, :logger
  end

  def self.authenticate!
    request = Typhoeus::Request.new(@auth_url)
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

  def self.send_notification(notification)
    authenticate!
    request = create_notification_request(notification)

    @hydra.queue(request)
    @hydra.run
    response = request.response
  end

  def self.send_batch_notifications(notifications)
    authenticate!
    requests = []
    errors = []
    notifications.each do |notification|
      request = create_notification_request(notification)
      requests << request
      request.method = :post
      request.on_complete do |response|
        if response.success?
          if response.body =~ /Error=(\w+)/
            errors << { :registration_id => notification[:registration_id], :error => $1 }
            @logger.info("Error sending: #{notification[:registration_id]}")
          else
            @logger.info("Sent notification: #{notification[:registration_id]}")
            requests.delete(request)
          end
        elsif response.code == 503
          @hydra.abort
          raise RuntimeError
        end
      end
      @hydra.queue(request)
    end
    begin 
      @hydra.run
    rescue RuntimeError
      requests.each do |failed_request|
        errors << { 
          :registration_id => failed_request.body.match(/registration_id=(\w+)/)[1], 
          :error => 503 
        }
      end
    end
    errors
  end

  private
  def self.build_post_body(options={})
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

  def self.create_notification_request(notification)
    request = Typhoeus::Request.new(@send_url)
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
