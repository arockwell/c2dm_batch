require 'spec_helper'

describe C2dmBatch::Sender do
  before do
    @config = YAML::load(File.open("config.yml"))
    @email = @config['server']['username']
    @password = @config['server']['password']
    @source = @config['server']['source']
    @reg_id = @config['client']['registration_id']
  end

  it "should give an auth token" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    auth_code = sender.authenticate!
    auth_code.should_not eql("")
  end

  it "should send a notifcation" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    sender.authenticate!
    notification = {
      :registration_id => @reg_id,
      :data => { 
        :alert => "5 NFL Players Who Won't Replicate Last Year's Success",
        :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
        :tag => "boston-college-football"
      }
    }
    sender.send_notification(notification)
  end
end
