require "pp"
require "bundler"

Bundler.require(:development)

$root = File.expand_path('../../', __FILE__)

require "#{$root}/lib/c2dm_batch"
