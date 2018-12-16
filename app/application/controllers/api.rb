require 'roda'

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
            path_request = PaperRequestPath.new(keyword, searchType)
            result = Service::ShowPaperList.new.call(
              keyword: keyword,
              searchType: searchType
            )

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code

            Representer::PaperList.new(
              result.value!.message
            ).to_json
          end

          routing.on String do |id|
            # GET /paper/id
            routing.get do
              # the reference and citation won't change that fast actually
              # use public - not contain sensitive information
              #response.cache_control public: true, max_age: 10#21_600
              Cache::Control.new(response).turn_on if Env.new(Api).production?
              result = Service::ShowPaperContent.new.call(id: id)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              # get main paper object value
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::TopPaper.new(
                result.value!.message
              ).to_json
            end
          end

          routing.is do
            # GET /paper?list={base64 json array of paper id}
            routing.get do
              result = Service::ListPapers.new.call(
                list_request: Value::ListRequest.new(routing.params)
              )

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::PaperList.new(result.value!.message).to_json
            end
          end
        end
      end
    end
  end
end