C2dmBatch
===========

A library to send c2dm notifications in parallel.

This code is based on https://github.com/amro/c2dm

Requirements
------------

<pre>
gem install typhoeus
</pre>

Send a single notification
--------------------------
<pre>
sender = C2dmBatch::Sender.new(email, password, source)
notification = {
  :registration_id => "your_reg_id",
    :data => { 
      :test => "test"
    }
}
sender.send_notification(notification)
</pre>

Send notifications in batch
-----------------------------

<pre>
sender = C2dmBatch::Sender.new(email, password, source)
notification = [
  {
    :registration_id => "your_reg_id",
      :data => { 
        :test => "foo"
      }
  },
  {
    :registration_id => "your_reg_id2",
      :data => { 
        :test => "bar"
      }
  }
]
errors = sender.send_batch_notification(notification)
</pre>

Using Typhoeus, the send_batch_notification will parallelize the request in up to 200 parallel requests. Once a request finishes, a new request will automatically get send out. If a request has an error, the notification that failed is returned.
