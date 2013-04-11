require 'spec_helper'

describe C2dmBatch do
  after do
    Typhoeus::Expectation.clear
  end

  before do
    @config = YAML::load(File.open("config.yml"))
    @c2dm_batch = C2dmBatch.new
    @c2dm_batch.email = @config['server']['username']
    @c2dm_batch.password = @config['server']['password']
    @c2dm_batch.source = @config['server']['source']
    @reg_id = @config['client']['registration_id']
  end

  it "should give an auth token" do
    auth_code = @c2dm_batch.authenticate!
    auth_code.should_not eql("")
  end

  it "should send a notifcation" do
    @c2dm_batch.send_notification(create_notification(@reg_id, "boston-college-football"))
  end

  it "should send notifications in batches" do
    teams = [ "buffalo-bills", "miami-dolphins", "new-york-jets"]
    notifications = []
    teams.each do |team|
      notifications << create_notification(@reg_id, team)
    end
    errors = @c2dm_batch.send_batch_notifications(notifications)
    errors.size.should == 0
  end

  it "should return InvalidRegistration and registration_id" do
    teams = [ "buffalo-bills", "miami-dolphins"]
    notifications = []
    bad_reg_id = "bad_reg_id"
    notifications << create_notification(bad_reg_id, teams[0])
    notifications << create_notification(@reg_id, teams[1])
    errors = @c2dm_batch.send_batch_notifications(notifications)
    errors.size.should == 1
    errors[0][:registration_id].should == bad_reg_id
    errors[0][:error].should == "InvalidRegistration"
  end

  it "should return MessageToBig status code" do
    notifications = []
    notifications << create_notification(@reg_id, "1" * 2048)
    errors = @c2dm_batch.send_batch_notifications(notifications)
    errors.size.should == 1
    errors[0][:registration_id].should == @reg_id
    errors[0][:error].should == "MessageTooBig"
  end

  it "should abort on 503 and return remaining requests" do
    hydra = Typhoeus::Hydra.new
    response = Typhoeus::Response.new(:code => 503, :headers => "", :body => "registration=123")
    Typhoeus.stub('https://android.apis.google.com/c2dm/send').and_return(response)
    @c2dm_batch.instance_variable_set("@hydra", hydra)
    teams = [ "buffalo-bills", "miami-dolphins", "new-york-jets"]
    notifications = []
    teams.each do |team|
      notifications << create_notification(@reg_id, team)
    end
    errors = @c2dm_batch.send_batch_notifications(notifications)
    errors.size.should == 3
    errors[0][:error].should == 503
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
