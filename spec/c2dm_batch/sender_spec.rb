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
    sender.send_batch_notifications(notifications)
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
