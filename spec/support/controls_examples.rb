# frozen_string_literal: true

shared_examples "a controls config" do
  let(:component) { Demo::ButtonComponent }
  let(:param) { :button_text }
  let(:value) { "OK" }
  let(:name) { nil }
  let(:group_id) { nil }

  it "#type" do
    expect(subject.type).to eq(type)
  end

  describe "#name" do
    it "by default is derived from the param" do
      expect(subject.name).to eq("Button Text")
    end

    context "with name" do
      let(:name) { "Button" }

      it "can be passed in the construcor" do
        expect(subject.name).to eq("Button")
      end
    end
  end

  describe "#valid?" do
    it "true for param that the component supports" do
      expect(subject.valid?).to eq(true)
    end

    context "without a value" do
      let(:value) { nil }

      it "is valid" do
        expect(subject.valid?).to eq(true)
      end
    end

    context "with unsupported param" do
      let(:param) { :foo }

      it "is invalid" do
        expect(subject.valid?).to eq(false)
        expect(subject.errors.size).to eq(1)
        expect(subject.errors[:param]).to eq(["is not included in the list"])
      end
    end

    context "without a component" do
      let(:component) { nil }

      it "is invalid" do
        expect(subject.valid?).to eq(false)
        expect(subject.errors.size).to eq(1)
        expect(subject.errors[:component]).to eq(["can't be blank"])
      end
    end
  end

  let(:expected_csf_value) { value }
  let(:csf_arg_type_control_overrides) { {} }
  let(:expected_csf_params) do
    {
      args: {
        button_text: expected_csf_value,
      },
      argTypes: {
        button_text: { control: { type: type }.merge(csf_arg_type_control_overrides), name: "Button Text" },
      },
    }
  end

  describe "#to_csf_params" do
    it "creates params" do
      expect(subject.to_csf_params).to eq(expected_csf_params)
    end

    context "with name" do
      let(:name) { "Text" }

      it "creates params" do
        name_params = { argTypes: { button_text: { name: "Text" } } }
        expect(subject.to_csf_params).to eq(expected_csf_params.deep_merge(name_params))
      end
    end

    it "calls validate!" do
      allow(subject).to receive(:validate!).and_raise ActiveModel::ValidationError.new(subject)

      expect { subject.to_csf_params }.to raise_error ActiveModel::ValidationError
      expect(subject).to have_received(:validate!).once
    end
  end

  let(:param_value) { "OK" }
  describe "#value_from_param" do
    it "parses param_value" do
      expect(subject.value_from_param(param_value)).to eq(value)
    end

    it "parses nil param_value" do
      expect(subject.value_from_param(nil)).to eq(nil)
    end
  end
end
