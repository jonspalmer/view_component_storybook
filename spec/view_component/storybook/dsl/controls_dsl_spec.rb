# frozen_string_literal: true

RSpec.describe ViewComponent::Storybook::Dsl::ControlsDsl do
  include described_class

  shared_examples "has controls attributes" do |control_attributes|
    it "has expected attributes" do
      expect(subject).to have_attributes(control_attributes)
    end
  end

  describe "#text" do
    subject { text("Jame Doe").param(:name) }

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::TextConfig,
                       param: :name,
                       name: "Name",
                       default_value: "Jame Doe"
                     }
  end

  describe "#boolean" do
    subject { boolean(true).param(:likes_people) }

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::BooleanConfig,
                       param: :likes_people,
                       name: "Likes People",
                       default_value: true
                     }
  end

  describe "#number" do
    context "with minimal args" do
      subject { number(2).param(:number_pets) }

      include_examples "has controls attributes",
                       {
                         class: ViewComponent::Storybook::Controls::NumberConfig,
                         type: :number,
                         param: :number_pets,
                         name: "Number Pets",
                         default_value: 2,
                         min: nil,
                         max: nil,
                         step: nil
                       }
    end

    context "with all args" do
      subject { number(2, min: 0, max: 10, step: 1).param(:number_pets) }

      include_examples "has controls attributes",
                       {
                         class: ViewComponent::Storybook::Controls::NumberConfig,
                         type: :number,
                         param: :number_pets,
                         name: "Number Pets",
                         default_value: 2,
                         min: 0,
                         max: 10,
                         step: 1
                       }
    end
  end

  describe "#range" do
    context "with minimal args" do
      subject { range(2).param(:number_pets) }

      include_examples "has controls attributes",
                       {
                         class: ViewComponent::Storybook::Controls::NumberConfig,
                         type: :range,
                         param: :number_pets,
                         name: "Number Pets",
                         default_value: 2,
                         min: nil,
                         max: nil,
                         step: nil
                       }
    end

    context "with all args" do
      subject { range(2, min: 0, max: 10, step: 1).param(:number_pets) }

      include_examples "has controls attributes",
                       {
                         class: ViewComponent::Storybook::Controls::NumberConfig,
                         type: :range,
                         param: :number_pets,
                         name: "Number Pets",
                         default_value: 2,
                         min: 0,
                         max: 10,
                         step: 1
                       }
    end
  end

  describe "#color" do
    subject { color("red").param(:favorite_color) }

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::ColorConfig,
                       param: :favorite_color,
                       name: "Favorite Color",
                       default_value: "red"
                     }
  end

  describe "#object" do
    subject { object({ hair: "Brown", eyes: "Blue" }).param(:other_things) }

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::ObjectConfig,
                       param: :other_things,
                       name: "Other Things",
                       default_value: { hair: "Brown", eyes: "Blue" }
                     }
  end

  %w[select multi-select radio inline-radio check inline-check].each do |type|
    dsl_method = type.underscore

    describe "##{dsl_method}" do
      subject { send(dsl_method, { hot_dog: "Hot Dog", pizza: "Pizza" }, "Pizza").param(:favorite_food) }

      include_examples "has controls attributes",
                       {
                         class: ViewComponent::Storybook::Controls::OptionsConfig,
                         type: type.to_sym,
                         param: :favorite_food,
                         name: "Favorite Food",
                         default_value: "Pizza",
                         options: { hot_dog: "Hot Dog", pizza: "Pizza" }
                       }
    end
  end

  describe "#custom" do
    subject do
      custom(first_name: "J.R.R.", last_name: "Tolkien") do |first_name:, last_name:|
        Author.new(first_name: first_name, last_name: last_name).full_name
      end.param(:author)
    end

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::CustomConfig,
                       param: :author,
                       name: "Author"
                     }

    it "returns cutom value from params" do
      from_params = subject.value_from_params({})
      expect(from_params).to eq("J.R.R. Tolkien")
    end
  end

  describe "#klazz" do
    subject do
      klazz(Author, first_name: "J.R.R.", last_name: "Tolkien").param(:author)
    end

    include_examples "has controls attributes",
                     {
                       class: ViewComponent::Storybook::Controls::CustomConfig,
                       param: :author,
                       name: "Author"
                     }

    it "returns cutom value from params" do
      from_params = subject.value_from_params({})
      expect(from_params).to be_a(Author)
      expect(from_params.full_name).to eq("J.R.R. Tolkien")
    end
  end
end
