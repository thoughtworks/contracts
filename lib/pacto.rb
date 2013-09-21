require 'pacto/version'

require 'httparty'
require 'hash_deep_merge'
require 'json'
require 'json-schema'
require 'json-generator'
require 'webmock'
require 'ostruct'
require 'erb'

require 'pacto/exceptions/invalid_contract.rb'
require 'pacto/extensions'
require 'pacto/request'
require 'pacto/response_adapter'
require 'pacto/response'
require 'pacto/stubs/built_in'
require 'pacto/stubs/stub_provider'
require 'pacto/instantiated_contract'
require 'pacto/contract'
require 'pacto/contract_factory'
require 'pacto/erb_processor'
require 'pacto/hash_merge_processor'
require 'pacto/stubs/built_in'
require 'pacto/configuration'
require 'pacto/meta_schema'

module Pacto
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  def self.validate_contract contract
    Pacto::MetaSchema.new.validate contract
    puts 'All contracts successfully meta-validated'
    true
  rescue InvalidContract => exception
    puts 'Validation errors detected'
    exception.errors.each do |error|
      puts "  Error: #{error}"
    end
    false
  end

  def self.build_from_file(contract_path, host, file_pre_processor = Pacto.configuration.preprocessor)
    ContractFactory.build_from_file(contract_path, host, file_pre_processor)
  end

  def self.register(name, contract)
    raise ArgumentError, "contract \" #{name}\" has already been registered" if registered.key?(name)
    registered[name] = contract
  end

  def self.use(contract_name, values = nil)
    raise ArgumentError, "contract \"#{contract_name}\" not found" unless registered.key?(contract_name)
    configuration.provider.values = values
    instantiated_contract = registered[contract_name].instantiate
    instantiated_contract.stub!
    instantiated_contract
  end

  def self.load(contract_name)
    build_from_file(path_for(contract_name), nil)
  end

  def self.registered
    @registered ||= {}
  end

  def self.unregister_all!
    @registered = {}
  end

  private

  def self.path_for(contract)
    File.join(configuration.contracts_path, "#{contract}.json")
  end
end
