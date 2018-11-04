# frozen_string_literal: true

module RefEm
  module Entity
  # Domain entity for paper
    class Paper < Dry::Struct
      include Dry::Types.module
    end
  end
end
