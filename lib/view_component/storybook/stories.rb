# frozen_string_literal: true

module ViewComponent
  module Storybook
    class Stories
      extend ActiveSupport::DescendantsTracker
      include ActiveModel::Validations

      class_attribute :story_configs, default: []
      class_attribute :parameters, :title, :stories_layout

      validate :valid_story_configs

      class << self
        def stories_title(title = nil)
          self.title = title unless title.nil?
        end

        def story(name, component = default_component, &block)
          story_config = StoryConfig.configure(story_id(name), name, component, layout, &block)
          story_configs << story_config
          story_config
        end

        def parameters(**params)
          self.parameters = params
        end

        def layout(layout = nil)
          # if no argument is passed act like a getter
          self.stories_layout = layout unless layout.nil?
          stories_layout
        end

        def to_csf_params
          validate!
          csf_params = { title: title }
          csf_params[:parameters] = parameters if parameters.present?
          csf_params[:stories] = story_configs.map(&:to_csf_params)
          csf_params
        end

        def write_csf_json
          json_path = File.join(stories_path, "#{stories_name}.stories.json")
          File.open(json_path, "w") do |f|
            f.write(JSON.pretty_generate(to_csf_params))
          end
          json_path
        end

        def stories_name
          name.chomp("Stories").underscore
        end

        # Returns all component stories classes.
        def all
          load_stories if descendants.empty?
          descendants
        end

        # Returns +true+ if the stories exist.
        def stories_exists?(stories_name)
          all.any? { |stories| stories.stories_name == stories_name }
        end

        # Find a component stories by its underscored class name.
        def find_stories(stories_name)
          all.find { |stories| stories.stories_name == stories_name }
        end

        # Returns +true+ if the story of the component stories exists.
        def story_exists?(name)
          story_configs.map(&:name).include?(name.to_sym)
        end

        # find the story by name
        def find_story(name)
          story_configs.find { |config| config.name == name.to_sym }
        end

        # validation - ActiveModel::Validations like but on the class vs the instance
        def valid?
          # use an instance so we can enjoy the benefits of ActiveModel::Validations
          @validation_instance = new
          @validation_instance.valid?
        end

        delegate :errors, to: :@validation_instance

        def validate!
          valid? || raise(ActiveModel::ValidationError, @validation_instance)
        end

        private

        def inherited(other)
          super(other)
          # setup class defaults
          other.title = other.stories_name.humanize.titlecase
          other.story_configs = []
        end

        def default_component
          name.chomp("Stories").constantize
        end

        def load_stories
          Dir["#{stories_path}/**/*_stories.rb"].sort.each { |file| require_dependency file } if stories_path
        end

        def stories_path
          Storybook.stories_path
        end

        def story_id(name)
          "#{stories_name}/#{name.to_s.parameterize}".underscore
        end
      end

      protected

      def valid_story_configs
        story_configs.reject(&:valid?).each do |story_config|
          errors.add(:story_configs, :invalid, value: story_config)
        end

        story_names = story_configs.map(&:name)
        duplicate_names = story_names.group_by(&:itself).map { |k, v| k if v.length > 1 }.compact
        return if duplicate_names.empty?

        errors.add(:story_configs, :invalid, message: "Stories #{'names'.pluralize(duplicate_names.count)} #{duplicate_names.to_sentence} are repeated")
      end
    end
  end
end
