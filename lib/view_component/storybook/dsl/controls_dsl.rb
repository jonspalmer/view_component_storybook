# frozen_string_literal: true

module ViewComponent
  module Storybook
    module Dsl
      module ControlsDsl
        def text(default_value)
          Controls::TextConfig.new(default_value)
        end

        def boolean(default_value)
          Controls::BooleanConfig.new(default_value)
        end

        def number(default_value, min: nil, max: nil, step: nil)
          Controls::NumberConfig.new(:number, default_value, min: min, max: max, step: step)
        end

        def range(default_value, min: nil, max: nil, step: nil)
          Controls::NumberConfig.new(:range, default_value, min: min, max: max, step: step)
        end

        def color(default_value, preset_colors: nil)
          Controls::ColorConfig.new(default_value, preset_colors: preset_colors)
        end

        def object(default_value)
          Controls::ObjectConfig.new(default_value)
        end

        def select(options, default_value)
          Controls::OptionsConfig.new(:select, options, default_value)
        end

        def multi_select(options, default_value)
          Controls::OptionsConfig.new(:'multi-select', options, default_value)
        end

        def radio(options, default_value)
          Controls::OptionsConfig.new(:radio, options, default_value)
        end

        def inline_radio(options, default_value)
          Controls::OptionsConfig.new(:'inline-radio', options, default_value)
        end

        def check(options, default_value)
          Controls::OptionsConfig.new(:check, options, default_value)
        end

        def inline_check(options, default_value)
          Controls::OptionsConfig.new(:'inline-check', options, default_value)
        end

        def array(default_value, separator = ",")
          Controls::ArrayConfig.new(default_value, separator)
        end

        def date(default_value)
          Controls::DateConfig.new(default_value)
        end

        def custom(*args, **kwargs, &block)
          Controls::CustomConfig.new.with_value(*args, **kwargs, &block)
        end

        def klazz(value_class, *args, **kwargs)
          Controls::CustomConfig.new.with_value(*args, **kwargs) do |*a, **kwa|
            value_class.new(*a, **kwa)
          end
        end

        Controls = ViewComponent::Storybook::Controls
      end
    end
  end
end
