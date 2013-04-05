$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'prism-residential-service-client'
require 'active_support/hash_with_indifferent_access'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

hydra = Typhoeus::Hydra.new

config_file_path = File.join( File.dirname(__FILE__), '..', 'config', 'service.yml.example' )
config_options = YAML.load_file(config_file_path)['test']
config = ActiveSupport::HashWithIndifferentAccess.new(config_options.merge hydra: hydra)

config.each do |attr_id, val|
  ResidentialService::Config.send("#{attr_id}=".to_sym, val)
end
