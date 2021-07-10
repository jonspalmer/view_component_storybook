# frozen_string_literal: true

module Demo
  class HeadingComponentStories < ViewComponent::Storybook::Stories
    stories_title 'Heading Component'

    story :default do
      controls do
        heading_text "Heading"
      end
    end
  end
end
