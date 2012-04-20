require 'rubygems'
require 'bundler'

Bundler.require

# Support files first
require 'active_support/core_ext/hash'
require 'active_support/json'

begin
  require 'active_support/hash_with_indifferent_access'
rescue
end

filepath = File.join( File.dirname(__FILE__), 'support', '*.rb' )
Dir.glob(filepath){|fname| require fname }

filepath = File.join( File.dirname(__FILE__), 'prism-residential-service-client', '*.rb' )
Dir.glob(filepath){|fname| require fname }
