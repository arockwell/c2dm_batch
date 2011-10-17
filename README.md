C2dmBatch
===========

A library to send c2dm notifications in parallel.

This code is based on https://github.com/amro/c2dm

Requirements
------------

<pre>
gem install typhoeus
</pre>

Configuration
-------------
C2dmBatch.email = 'your_c2dm_sender@gmail.com' 
C2dmBatch.password = 'password'
C2dmBatch.source = 'your app name'
C2dmBatch.logger = Logger.new(STDOUT) # default logger 

Send a single notification
--------------------------
<pre>
C2dmBatch.email = 'your_c2dm_sender@gmail.com' 
C2dmBatch.password = 'password'
C2dmBatch.source = 'your app name'
notification = {
  :registration_id => "your_reg_id",
    :data => { 
      :test => "test"
    }
}
C2dmBatch.send_notification(notification)
</pre>

Send notifications in batch
-----------------------------

<pre>
C2dmBatch.email = 'your_c2dm_sender@gmail.com' 
C2dmBatch.password = 'password'
C2dmBatch.source = 'your app name'
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
errors = C2dmBatch.send_batch_notification(notification)
</pre>

Using Typhoeus, the send_batch_notification will parallelize the request in up to 200 parallel requests. Once a request finishes, a new request will automatically get send out. The return value is an array of hashes. The hash is of the form { :registration_id => 'reg_id', :error => 'error_code' }

Possible Error Codes
--------------------
The error code and description are taken from the official c2dm docuementation at: http://code.google.com/android/c2dm/

* QuotaExceeded — Too many messages sent by the sender. Retry after a while.
* DeviceQuotaExceeded — Too many messages sent by the sender to a specific device. Retry after a while.
* InvalidRegistration — Missing or bad registration_id. Sender should stop sending messages to this device.
* NotRegistered — The registration_id is no longer valid, for example user has uninstalled the application or turned off notifications. Sender should stop sending messages to this device.
* MessageTooBig — The payload of the message is too big, see the limitations. Reduce the size of the message.
* MissingCollapseKey — Collapse key is required. Include collapse key in the request.
* 503 - Must retry later. c2dm batch aborts all in-flight requests and returns all unsent requests with a 503 error code. Resending with honoring the Retry-After and exponentail backoff are not implemented. 
