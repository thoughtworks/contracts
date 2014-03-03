require 'spec_helper'

describe Pacto do
  around(:each) do |example|
    $stdout = StringIO.new
    example.run
    $stdout = STDOUT
  end

  def output
    $stdout.string.strip
  end

  def mock_validation(errors)
    expect(JSON::Validator).to receive(:fully_validate).with(any_args).and_return errors
  end

  describe '.validate_contract' do
    context 'valid' do
      it 'displays a success message and return true' do
        mock_validation []
        success = Pacto.validate_contract 'my_contract.json'
        expect(output).to eq 'Validating my_contract.json'
        expect(success).to be_true
      end
    end

    context 'invalid' do
      it 'displays one error messages and return false' do
        mock_validation ['Error 1']
        success = Pacto.validate_contract 'my_contract.json'
        expect(output).to match(/error/)
        expect(success).to be_false
      end

      it 'displays several error messages and return false' do
        mock_validation ['Error 1', 'Error 2']
        success = Pacto.validate_contract 'my_contract.json'
        expect(success).to be_false
      end
    end
  end

  describe 'loading contracts' do
    let(:contracts_path) { 'path/to/dir' }
    let(:host) { 'localhost' }

    it 'instantiates a contract list' do
      expect(Pacto::ContractList).to receive(:new) do |contracts|
        contracts.each { |contract| expect(contract).to be_a_kind_of(Pacto::Contract) }
      end
      Pacto.load_contracts('spec/integration/data/', host)
    end
  end
end
