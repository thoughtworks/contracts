require "pacto/version"

require "httparty"
require "hash_deep_merge"
require "json"
require "json-schema"
require "json-generator"
require "webmock"
require "ostruct"
require "erb"

require "pacto/exceptions/invalid_contract.rb"
require "pacto/extensions"
require "pacto/request"
require "pacto/response_adapter"
require "pacto/response"
require "pacto/stubs/webmock_provider"
require "pacto/instantiated_contract"
require "pacto/contract"
require "pacto/contract_factory"
require "pacto/file_pre_processor"
require "pacto/meta_schema"

module Pacto
  def self.validate_contract contract
    begin
      Pacto::MetaSchema.new.validate contract
      puts "All contracts successfully meta-validated"
      true
    rescue InvalidContract => e
      puts "Validation errors detected"
      e.errors.each do |e|
        puts "  Error: #{e}"
      end
      false
    end
  end

  def self.build_from_file(contract_path, host, file_pre_processor=FilePreProcessor.new)
    ContractFactory.build_from_file(contract_path, host, file_pre_processor)
  end

  def self.register(name, contract)
    raise ArgumentError, "contract \" #{name}\" has already been registered" if registered.has_key?(name)
    registered[name] = contract
  end

  def self.use(contract_name, values = nil)
    raise ArgumentError, "contract \"#{contract_name}\" not found" unless registered.has_key?(contract_name)
    instantiated_contract = registered[contract_name].instantiate(values)
    instantiated_contract.stub!
    instantiated_contract
  end

  def self.registered
    @registered ||= {}
  end

  def self.unregister_all!
    @registered = {}
  end
end
