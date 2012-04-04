require 'rubygems'
require 'bundler'

Bundler.require

filepath = File.join(File.dirname(__FILE__), '**', '*.rb')
Dir.glob(filepath){|fname| require fname }
