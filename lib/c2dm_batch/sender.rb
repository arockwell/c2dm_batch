module C2dmBatch
  class Sender
    AUTH_URL = 'https://www.google.com/accounts/ClientLogin'


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
      auth_code = ""
      if response.success?
        response.body.split("\n").each do |line|
          if line =~ /^Auth=/
            auth_code = line.gsub('Auth=', '')
          end
        end
      end
      return auth_code
    end
  end

end
