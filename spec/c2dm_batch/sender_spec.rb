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
    sender.send_notification(create_notification(@reg_id, "boston-college-football"))
  end

  it "should send notifications in batches" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    teams = [ "buffalo-bills", "miami-dolphins", "new-york-jets"]
    notifications = []
    teams.each do |team|
      notifications << create_notification(@reg_id, team)
    end
    errors = sender.send_batch_notifications(notifications)
    errors.size.should == 0
  end

  it "should return InvalidRegistration and registration_id" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    teams = [ "buffalo-bills", "miami-dolphins"]
    notifications = []
    bad_reg_id = "bad_reg_id"
    notifications << create_notification(bad_reg_id, teams[0])
    notifications << create_notification(@reg_id, teams[1])
    errors = sender.send_batch_notifications(notifications)
    errors.size.should == 1
    errors[0][:registration_id].should == bad_reg_id
    errors[0][:error].should == "InvalidRegistration"
  end

  it "should return MessageToBig status code" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    notifications = []
    notifications << create_notification(@reg_id, "1" * 1025)
    errors = sender.send_batch_notifications(notifications)
    errors[0][:registration_id].should == @reg_id
    errors[0][:error].should == "MessageTooBig"
  end

  private
  def create_notification(reg_id, team)
      {
        :registration_id => reg_id,
        :collapse_key => "#{1 + rand(100000)}",
        :data => { 
          :alert => team,
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => team
        }
      }
  end

end
