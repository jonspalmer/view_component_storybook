# frozen_string_literal: true

module Demo
  class HeadingComponent < ViewComponent::Base
    def initialize(heading_text:)
      super
      @heading_text = heading_text
    end

    private

    attr_reader :heading_text
  end
end
