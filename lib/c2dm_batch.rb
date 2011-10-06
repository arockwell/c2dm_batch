require "rubygems"
require "bundler"
require "yaml"
require "cgi"
require "typhoeus"

Bundler.require(:default)

$:.unshift File.dirname(__FILE__)

module C2dmBatch
end

require 'c2dm_batch/core'
