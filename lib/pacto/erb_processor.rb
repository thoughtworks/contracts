module Pacto
  class ERBProcessor
    def process(contract, values = {})
      values ||= {}
      erb = ERB.new(contract)
      erb_result = erb.result hash_binding(values)
      Logger.instance.debug "Processed contract: #{erb_result.inspect}"
      erb_result
    end

    private

    def hash_binding(values)
      namespace = OpenStruct.new(values)
      namespace.instance_eval { binding }
    end
  end
end
