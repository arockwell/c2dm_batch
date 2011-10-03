require 'spec_helper'

describe C2dmBatch::Sender do
  before do
    @config = YAML::load(File.open("config.yml"))
    @email = @config['server']['username']
    @password = @config['server']['password']
    @source = @config['server']['source']
  end

  it "should give an auth token" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    auth_code = sender.authenticate!
    auth_code.should_not eql("")
  end

end
