module RefEm
  module Representer
    # Represents PaperList information for API output
    class PaperList < Roar::Decorator
      include Roar::JSON

      collection :citations, extend: Representer::Citation, class: OpenStruct
    end
  end
end
