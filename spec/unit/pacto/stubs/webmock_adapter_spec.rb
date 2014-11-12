module Pacto
  module Stubs
    # FIXME: Review this test and see which requests are Pacto vs WebMock, then use Fabricate
    describe WebMockAdapter do
      let(:middleware) { double('middleware') }

      let(:request) do
        Fabricate(:request_clause,
                  host: 'http://localhost',
                  http_method: http_method,
                  path: '/hello_world',
                  headers: { 'Accept' => 'application/json' },
                  params: { 'foo' => 'bar' }
        )
      end

      let(:http_method) { :get }

      let(:response) do
        Fabricate(
          :response_clause,
          status: 200,
          headers: {},
          schema: {
            type: 'object',
            required: ['message'],
            properties: {
              message: {
                type: 'string',
                default: 'foo'
              }
            }
          }
        )
      end

      let(:contract) do
        Fabricate(:contract, request: request, response: response)
      end

      let(:body) do
        { 'message' => 'foo' }
      end

      let(:stubbed_request) do
        {
          path: nil
        }
      end

      let(:request_pattern) { double('request_pattern') }

      subject(:adapter) { WebMockAdapter.new middleware }

      before(:each) do
        allow(stubbed_request).to receive(:to_return).with(no_args)
        allow(stubbed_request).to receive(:request_pattern).and_return request_pattern
      end

      describe '#initialize' do
        it 'sets up a hook' do
          expect(WebMock).to receive(:after_request) do | _arg, &block |
            expect(block.parameters.size).to eq(2)
          end

          Pacto.configuration.adapter # (rather than WebMockAdapter.new, to prevent rpec after block from creating a second instance
        end
      end

      describe '#process_hooks' do
        let(:request_signature) { double('request_signature') }

        it 'calls the middleware for processing' do
          expect(middleware).to receive(:process).with(a_kind_of(Pacto::PactoRequest), a_kind_of(Pacto::PactoResponse))
          adapter.process_hooks request_signature, response
        end
      end

      describe '#stub_request!' do
        before(:each) do
          expect(WebMock).to receive(:stub_request) do | _method, url |
            stubbed_request[:path] = url
            stubbed_request
          end
        end

        context 'when the response body is an object' do
          let(:body) do
            { 'message' => 'foo' }
          end

          context 'a GET request' do
            let(:http_method) { :get }

            it 'uses WebMock to stub the request' do
              expect(request_pattern).to receive(:with).
                with(headers: request.headers, query: request.params).
                and_return(stubbed_request)
              adapter.stub_request! contract
            end
          end

          context 'a POST request' do
            let(:http_method) { :post }

            it 'uses WebMock to stub the request' do
              expect(request_pattern).to receive(:with).
                with(headers: request.headers, body: request.params).
                and_return(stubbed_request)
              adapter.stub_request! contract
            end
          end

          context 'a request with no headers' do
            let(:request) do
              Fabricate(:request_clause,
                        host: 'http://localhost',
                        http_method: :get,
                        path: '/hello_world',
                        headers: {},
                        params: { 'foo' => 'bar' }
              )
            end

            it 'uses WebMock to stub the request' do
              expect(request_pattern).to receive(:with).
                with(query: request.params).
                and_return(stubbed_request)
              adapter.stub_request! contract
            end
          end

          context 'a request with no params' do
            let(:request) do
              Fabricate(:request_clause,
                        host: 'http://localhost',
                        http_method: :get,
                        path: '/hello_world',
                        headers: {},
                        params: {}
              )
            end

            it 'uses WebMock to stub the request' do
              expect(request_pattern).to_not receive(:with)
              adapter.stub_request! contract
            end
          end
        end
      end
    end
  end
end
