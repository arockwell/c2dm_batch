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
    notification = {
      :registration_id => @reg_id,
      :data => { 
        :alert => "5 NFL Players Who Won't Replicate Last Year's Success",
        :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
        :tag => "boston-college-football"
      }
    }
    #sender.send_notification(notification)
  end

  it "should send notifications in batches" do
    sender = C2dmBatch::Sender.new(@email, @password, @source)
    notifications = [
      {
        :registration_id => @reg_id,
        :collapse_key => "1",
        :data => { 
          :alert => "1 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "buffalo-bills"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "2",
        :data => { 
          :alert => "2 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "miami-dolphins"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "3",
        :data => { 
          :alert => "3 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "new-york-jets"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "4",
        :data => { 
          :alert => "4 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "baltimore-ravens"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "5",
        :data => { 
          :alert => "5 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "cincinnati-bengals"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "6",
        :data => { 
          :alert => "6 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "cleveland-browns"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "7",
        :data => { 
          :alert => "7 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "pittsburgh-steelers"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "8",
        :data => { 
          :alert => "8 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "houston-texans"
        }
      },
      {
        :registration_id => @reg_id,
        :collapse_key => "9",
        :data => { 
          :alert => "9 NFL Players Who Won't Replicate Last Year's Success",
          :url => "/articles/816975-nfl-5-players-who-wont-replicate-last-years-success",
          :tag => "indianapolis-colts"
        }
      }
    ]
    sender.send_batch_notifications(notifications)
  end
end
