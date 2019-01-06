# frozen_string_literal: true

require 'roda'
require_relative 'lib/init'

module RefEm
  # Web App
  class Api < Roda
    include RouteHelpers
    plugin :halt
    plugin :all_verbs
    plugin :caching

    use Rack::MethodOverride

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "RefEm API v1 at /api/v1/ in #{Api.environment} mode"

        result_response = Representer::HttpResponse.new(
          Value::Result.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'paper' do
          routing.on String, String do |searchType, keyword|
            # GET /paper/keyword?searchType={title, keyword}
            result = Service::ShowPaperList.new.call(
              keyword: keyword,
              searchType: searchType
            )

            Representer::For.new(result).status_and_body(response)
          end

          routing.on String do |id|
            # GET /paper/id
            routing.get do
              @api = RefEm::Api
              # Cache::Control.new(response).turn_on if RefEm::Env.new(@api).production?

              path_request = PaperRequestPath.new(id)
              puts "--------------------------id: #{path_request.id}------------------"
              request_id = [request.env, request.path, Time.now.to_f].hash

              puts "request path: #{path_request}"
              result = Service::ShowPaperContent.new.call(
                requested: path_request,
                request_id: request_id,
                config: Api.config
              )

              Representer::For.new(result).status_and_body(response)
            end
          end

          routing.is do
            # GET /paper?list={base64 json array of paper id}
            routing.get do
              result = Service::ListPapers.new.call(
                list_request: Value::ListRequest.new(routing.params)
              )
              Representer::For.new(result).status_and_body(response)
            end
          end
        end
      end
    end
  end
end
