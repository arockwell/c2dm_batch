require "rubygems"
require "yaml"
require "cgi"
gem 'typhoeus', '= 0.2.4'
require "typhoeus"
require 'logger'
require 'json'

$:.unshift File.dirname(__FILE__)

module C2dmBatch
end

require 'c2dm_batch/core'
