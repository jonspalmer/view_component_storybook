# frozen_string_literal: true

module ViewComponent
  module Storybook
    class ControlMethodArgs
      attr_reader :target_method_arg_names, :args, :kwargs, :block

      def initialize(target_method, *args, **kwargs, &block)
        @target_method_arg_names = MethodArgNames.new(target_method)
        @args = args
        @kwargs = kwargs
        @block = block
        assign_control_params
      end

      def method_args(params)
        args_from_params = args.map do |arg|
          value_from_params(arg, params)
        end
        kwargs_from_params = kwargs.transform_values do |arg|
          value_from_params(arg, params)
        end

        MethodArgs.new(args_from_params, kwargs_from_params, block)
      end

      def controls
        args.concat(kwargs.values).select(&method(:control_config?))
      end

      private

      def assign_control_params
        args.each_with_index do |arg, index|
          arg.param = target_method_arg_names.arg_name(index) if control_config?(arg) && arg.param.nil?
        end

        kwargs.each do |key, arg|
          arg.param = key if control_config?(arg) && arg.param.nil?
        end
      end

      def value_from_params(arg, params)
        if control_config?(arg)
          value = arg.value_from_params(params)
          value = arg.value if value.nil? # nil only not falsey
          value
        else
          arg
        end
      end

      def control_config?(arg)
        arg.is_a?(ViewComponent::Storybook::Controls::ControlConfig)
      end

      class MethodArgs
        attr_reader :args, :kwargs, :block

        def initialize(args, kwargs, block)
          @args = args
          @kwargs = kwargs
          @block = block
        end
      end

      class MethodArgNames
        KWARG_TYPES = [:key, :keyreq].freeze
        ARG_TYPES = [:req, :opt].freeze
        KWARG_REST = :keyrest
        REST = :rest

        attr_reader :target_method

        def initialize(target_method)
          @target_method = target_method
        end

        def arg_name(pos)
          if pos < named_arg_count
            arg_names[pos]
          else
            offset_pos = pos - named_arg_count
            "#{rest_arg_name}#{offset_pos}".to_sym
          end
        end

        def include_kwarg?(arg_name)
          supports_keyrest? || kwarg_names.includes?(arg_name)
        end

        def include_arg(pos)
          supports_rest? || pos < named_arg_count
        end

        private

        def parameters
          @parameters ||= target_method.parameters
        end

        def kwarg_names
          @kwarg_names ||= parameters.select do |type, name|
            name if KWARG_TYPES.include?(type)
          end.compact
        end

        def arg_names
          @arg_names ||= parameters.map do |type, name|
            name if ARG_TYPES.include?(type)
          end.compact
        end

        def named_arg_count
          @named_arg_count ||= arg_names.count
        end

        def rest_arg_name
          @rest_arg_name ||= parameters.map { |type, name| name if type == REST }.first
        end

        def supports_keyrest?
          @supports_keyrest ||= parameters.map(&:first).include?(KWARG_REST)
        end

        def supports_rest?
          @supports_rest ||= parameters.map(&:first).include?(REST)
        end
      end
    end
  end
end
