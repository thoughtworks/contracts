require 'erb'

module Pacto
  # Builds {Pacto::Contract} instances from Pacto's native Contract format.
  class NativeContractFactory
    attr_reader :schema

    def initialize(options = {})
      @schema = options[:schema] || MetaSchema.new
    end

    def build_from_file(contract_path, host)
      definition = parse_json(contract_path)
      schema.validate definition

      body_to_schema(definition, 'request', contract_path)
      body_to_schema(definition, 'response', contract_path)
      method_to_http_method(definition, contract_path)

      request = RequestClause.new(definition['request'].merge('host' => host))
      response = ResponseClause.new(definition['response'])
      Contract.new(request: request, response: response, file: contract_path, name: definition['name'], examples: definition['examples'])
    end

    def files_for(contracts_dir)
      full_path = Pathname.new(contracts_dir).realpath

      if  full_path.directory?
        all_json_files = "#{full_path}/**/*{.json,.json.erb}"
        Dir.glob(all_json_files).map do |f|
          Pathname.new(f)
        end
      else
        [full_path]
      end
    end

    private

    def parse_json(path)
      contents = File.read(path)
      contents = ERB.new(contents).result if path.to_s.end_with? '.erb'
      JSON.parse(contents)
    end

    def body_to_schema(definition, section, file)
      schema = definition[section].delete 'body'
      return nil unless schema

      Pacto::UI.deprecation "Contract format deprecation: #{section}:body will be moved to #{section}:schema (#{file})"
      definition[section]['schema'] = schema
    end

    def method_to_http_method(definition, file)
      method = definition['request'].delete 'method'
      return nil unless method

      Pacto::UI.deprecation "Contract format deprecation: request:method will be moved to request:http_method (#{file})"
      definition['request']['http_method'] = method
    end
  end
end

factory = Pacto::NativeContractFactory.new

Pacto::ContractFactory.add_factory(:native, factory)
Pacto::ContractFactory.add_factory(:default, factory)
