# frozen_string_literal: true

# Represents paper_id (MS) and request_id (queue) information for queue request
module RefEm
  module Representer
    # Representer object for paper fetching requests
    class PaperRequest < Roar::Decorator
      include Roar::JSON

      property :paper_id
      property :request_id
    end
  end
end
