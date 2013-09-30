module Pacto
  class Configuration
    attr_accessor :preprocessor, :postprocessor, :provider, :strict_matchers, :contracts_path, :logger
    attr_reader :callback

    def initialize
      @preprocessor = ERBProcessor.new
      @postprocessor = HashMergeProcessor.new
      @provider = Pacto::Stubs::BuiltIn.new
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger.instance
      @logger.level = :debug if ENV['PACTO_DEBUG']
      @callback = Pacto::Hooks::ERBHook.new
    end

    def register_contract(contract = nil, *tags)
      Pacto.register_contract(contract, *tags)
    end

    def register_callback(callback = nil, &block)
      if block_given?
        @callback = Pacto::Callback.new(&block)
      else
        raise 'Expected a Pacto::Callback' unless callback.is_a? Pacto::Callback
        @callback = callback
      end
    end
  end
end
