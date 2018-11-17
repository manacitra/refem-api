# frozen_string_literal: true

module Views
    # View for a single reference entity
    class Reference
      def initialize(reference, index = nil)
        @reference = reference
        @index = index
      end
  
      def detail_link
        
      end
  
      def index_str
        "#{@index+1}."
      end
  
      def title
        @reference.title
      end
  
    end
  end