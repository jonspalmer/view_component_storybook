# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Dsl
      class StoryDsl
        include ControlsDsl

        def self.evaluate!(story_config, &block)
          new(story_config).instance_eval(&block)
        end

        def parameters(**params)
          story_config.parameters = params
        end

        def controls(&block)
          ActiveSupport::Deprecation.warn("`controls` will be removed in v1.0.0. Use `#constructor` instead.")
          controls_dsl = LegacyControlsDsl.new
          controls_dsl.instance_eval(&block)

          controls_hash = controls_dsl.controls.index_by(&:param)
          story_config.constructor_args(**controls_hash)
        end

        def layout(layout)
          story_config.layout = layout
        end

        def content(&block)
          story_config.content_block = block
        end

        def constructor(*args, **kwargs, &block)
          story_config.constructor_args(*args, **kwargs)
          story_config.content_block = block
        end

        delegate :component, to: :story_config

        private

        attr_reader :story_config

        def initialize(story_config)
          @story_config = story_config
        end
      end
    end
  end
end
