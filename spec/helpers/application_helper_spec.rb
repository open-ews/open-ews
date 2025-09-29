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
      expect(helper.pluralize_model(2, Beneficiary.model_name, locale: :km)).to eq("2 សមាជិកទំនាក់ទំនង")

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

  describe "#dashboard_summary_description" do
    it "translates a dashboard summary description" do
      expect(
        helper.dashboard_summary_description(
          0,
          Beneficiary.model_name,
          past_participle: "registered",
          time_period: 30,
          unit: "day"
        )
      ).to eq("0 beneficiaries were registered in the last 30 days")

      expect(
        helper.dashboard_summary_description(
          1,
          Beneficiary.model_name,
          past_participle: "registered",
          time_period: 30,
          unit: "day"
        )
      ).to eq("1 beneficiary was registered in the last 30 days")

      expect(
        helper.dashboard_summary_description(
          2,
          Beneficiary.model_name,
          past_participle: "registered",
          time_period: 1,
          unit: "year"
        )
      ).to eq("2 beneficiaries were registered in the last 1 year")

      expect(
        helper.dashboard_summary_description(
          150,
          Beneficiary.model_name,
          past_participle: "registered",
          time_period: 30,
          unit: "day",
          locale: :km
        )
      ).to eq("150 សមាជិកទំនាក់ទំនងត្រូវបានចុះឈ្មោះក្នុង30 ថ្ងៃចុងក្រោយ")

      expect(
        helper.dashboard_summary_description(
          150,
          Beneficiary.model_name,
          past_participle: "registered",
          time_period: 30,
          unit: "day",
          locale: :lo
        )
      ).to eq("150 ຜູ້ໄດ້ຮັບຜົນປະໂຫຍດຖືກເຈົາທະບຽນໃນ30 ມື້ທີ່ຜ່ານມາ")
    end
  end
end
