module Pacto
  describe Logger do
    before do
      logger.log logger_lib
    end

    subject(:logger) { described_class.instance }
    let(:logger_lib) { ::Logger.new(StringIO.new) }

    it 'delegates debug to the logger lib' do
      logger_lib.should_receive(:debug)
      logger.debug
    end

    it 'delegates info to the logger lib' do
      logger_lib.should_receive(:info)
      logger.info
    end

    it 'delegates warn to the logger lib' do
      logger_lib.should_receive(:warn)
      logger.warn
    end

    it 'delegates error to the logger lib' do
      logger_lib.should_receive(:error)
      logger.error
    end

    it 'delegates fatal to the logger lib' do
      logger_lib.should_receive(:error)
      logger.error
    end

    it 'has the default log level as error' do
      expect(logger.level).to eq :error
    end

    it 'provides access to the log level' do
      logger.level = :info
      expect(logger.level).to eq :info
    end
  end
end
