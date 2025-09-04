require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#flash_class' do
    it 'returns flash alert class name based on given type' do
      expect(helper.flash_class('notice')).to eq 'alert alert-info'
      expect(helper.flash_class('success')).to eq 'alert alert-success'
      expect(helper.flash_class('error')).to eq 'alert alert-danger'
      expect(helper.flash_class('alert')).to eq 'alert alert-danger'
    end
  end

  describe "#pluralize_model" do
    it "pluralizes the model" do
      expect(helper.pluralize_model(0, Beneficiary.model_name)).to eq("0 beneficiaries")
      expect(helper.pluralize_model(1, Beneficiary.model_name)).to eq("1 beneficiary")
      expect(helper.pluralize_model(2, Beneficiary.model_name)).to eq("2 beneficiaries")
      expect(helper.pluralize_model(1245955, Beneficiary.model_name)).to eq("1,245,955 beneficiaries")

      expect(
        helper.pluralize_model(
          1245955,
          Beneficiary.model_name,
          formatter: ->(count) { ActiveSupport::NumberHelper.number_to_human(count) }
        )
      ).to eq("1.25 million beneficiaries")

      expect(
        helper.pluralize_model(
          1,
          Beneficiary.model_name,
          formatter: ->(count) { ActiveSupport::NumberHelper.number_to_human(count) }
        )
      ).to eq("1 beneficiary")
    end
  end
end
