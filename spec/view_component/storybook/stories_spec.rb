# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::Stories do
  describe ".valid?" do
    it "duplicate stories are invalid" do
      expect(Invalid::DuplicateStoryStories.valid?).to eq(false)
      expect(Invalid::DuplicateStoryStories.errors[:story_configs].length).to eq(1)
    end

    it "is invalid if stories are invalid" do
      expect(Invalid::DuplicateControlsStories.valid?).to eq(false)
      expect(Invalid::DuplicateControlsStories.errors[:story_configs].length).to eq(1)
    end
  end

  describe ".to_csf_params" do
    it "converts" do
      expect(ContentComponentStories.to_csf_params).to eq(
        title: "Content Component",
        stories: [
          {
            name: :default,
            parameters: {
              server: { id: "content_component/default" }
            }
          },
          {
            name: :with_helper_content,
            parameters: {
              server: { id: "content_component/with_helper_content" }
            }
          }
        ]
      )
    end

    it "converts kwargs" do
      expect(KwargsComponentStories.to_csf_params).to eq(
        title: "Kwargs Component",
        stories: [
          {
            name: :default,
            parameters: {
              server: { id: "kwargs_component/default" }
            },
            args: {
              message: "Hello World!",
              param: 1,
              other_param: true,
            },
            argTypes: {
              message: { control: { type: :text }, name: "Message" },
              param: { control: { type: :number }, name: "Param" },
              other_param: { control: { type: :boolean }, name: "Other Param" },
            }
          }
        ]
      )
    end

    it "converts kitchen sink" do
      expect(KitchenSinkComponentStories.to_csf_params).to eq(
        title: "Kitchen Sink Component",
        stories: [
          {
            name: :jane_doe,
            parameters: {
              server: { id: "kitchen_sink_component/jane_doe" }
            },
            args: {
              name: "Jane Doe",
              birthday: Time.utc(1950, 3, 26).iso8601,
              favorite_color: "red",
              like_people: true,
              number_pets: 2,
              sports: %w[football baseball],
              favorite_food: "Ice Cream",
              mood: "Happy",
              other_things: { eyes: "Blue", hair: "Brown" }

            },
            argTypes: {
              name: { control: { type: :text }, name: "Name" },
              birthday: { control: { type: :date }, name: "Birthday" },
              favorite_color: { control: { type: :color }, name: "Favorite Color" },
              like_people: { control: { type: :boolean }, name: "Like People" },
              number_pets: { control: { type: :number }, name: "Number Pets" },
              sports: { control: { type: :array, separator: "," }, name: "Sports" },
              favorite_food: {
                control: {
                  type: :select,
                  options: { burgers: "Burgers", hot_dog: "Hot Dog", ice_cream: "Ice Cream", pizza: "Pizza" }
                },
                name: "Favorite Food",
              },
              mood: {
                control: {
                  type: :radio,
                  options: { happy: "Happy", sad: "Sad", angry: "Angry", content: "Content" },
                },
                name: "Mood"
              },
              other_things: { control: { type: :object }, name: "Other Things" },
            }
          }
        ]
      )
    end

    it "converts Stories with namespaces" do
      expect(Demo::ButtonComponentStories.to_csf_params).to eq(
        title: "Demo/Button Component",
        stories: [
          {
            name: :short_button,
            parameters: {
              server: { id: "demo/button_component/short_button" }
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: :medium_button,
            parameters: {
              server: { id: "demo/button_component/medium_button" }
            },
            args: {
              button_text: "Push Me!"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: :long_button,
            parameters: {
              server: { id: "demo/button_component/long_button" }
            },
            args: {
              button_text: "Really Really Long Button Text"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          }
        ]
      )
    end

    it "converts Stories with customer Stories title" do
      expect(Demo::HeadingComponentStories.to_csf_params).to eq(
        title: "Heading Component",
        stories: [
          {
            name: :default,
            parameters: {
              server: { id: "demo/heading_component/default" }
            },
            args: {
              heading_text: "Heading"
            },
            argTypes: {
              heading_text: { control: { type: :text }, name: "Heading Text" }
            }
          }
        ]
      )
    end

    it "converts Stories with parameters" do
      expect(ParametersStories.to_csf_params).to eq(
        title: "Parameters",
        parameters: { size: :small },
        stories: [
          {
            name: :stories_parameters,
            parameters: {
              server: { id: "parameters/stories_parameters" }
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: :stories_parameter_override,
            parameters: {
              server: { id: "parameters/stories_parameter_override" },
              size: :large,
              color: :red,
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          },
          {
            name: :additional_parameters,
            parameters: {
              server: { id: "parameters/additional_parameters" },
              color: :red,
            },
            args: {
              button_text: "OK"
            },
            argTypes: {
              button_text: { control: { type: :text }, name: "Button Text" }
            }
          }
        ]
      )
    end

    it "raises an exception if stories are invalid" do
      expect { Invalid::DuplicateStoryStories.to_csf_params }.to raise_exception(ActiveModel::ValidationError)
    end

    it "raises an exception if a story_config is invalid" do
      expect { Invalid::DuplicateControlsStories.to_csf_params }.to raise_exception(ActiveModel::ValidationError)
    end
  end

  describe ".write_csf_json" do
    subject { ContentComponentStories.write_csf_json }

    after do
      File.delete(subject)
    end

    it "writes stories to json files" do
      json_file = File.read(subject)
      expect(json_file).to eq(
        <<~JSON.strip
          {
            "title": "Content Component",
            "stories": [
              {
                "name": "default",
                "parameters": {
                  "server": {
                    "id": "content_component/default"
                  }
                }
              },
              {
                "name": "with_helper_content",
                "parameters": {
                  "server": {
                    "id": "content_component/with_helper_content"
                  }
                }
              }
            ]
          }
        JSON
      )
    end
  end

  describe ".all" do
    it "has all stories" do
      expect(described_class.all).to eq [
        ContentComponentStories,
        Demo::ButtonComponentStories,
        Demo::HeadingComponentStories,
        Invalid::DuplicateControlsStories,
        Invalid::DuplicateStoryStories,
        KitchenSinkComponentStories,
        KwargsComponentStories,
        LayoutStories,
        NoLayoutStories,
        ParametersStories
      ]
    end
  end

  describe ".find_stories" do
    it "returns the Stories if they exist" do
      expect(described_class.find_stories("demo/button_component")).to eq Demo::ButtonComponentStories
    end

    it "returns nil if no stories exists" do
      expect(described_class.find_stories("foo/button_component")).to eq nil
    end
  end

  describe ".exists?" do
    it "is true for stories that exist" do
      expect(described_class.stories_exists?("demo/button_component")).to eq true
    end

    it "is false for stories that doesn't exist" do
      expect(described_class.stories_exists?("foo/button_component")).to eq false
    end
  end

  describe ".story_exists?" do
    it "is true for a story that exists" do
      expect(Demo::ButtonComponentStories.story_exists?(:short_button)).to eq true
    end

    it "can be called with a string" do
      expect(Demo::ButtonComponentStories.story_exists?("short_button")).to eq true
    end

    it "is false for a story that dones't exist" do
      expect(Demo::ButtonComponentStories.story_exists?(:foo_button)).to eq false
    end
  end
end
