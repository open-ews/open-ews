FactoryBot.define do
  sequence(:phone_number, "855972345678")

  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :auth_token do
    SecureRandom.alphanumeric(43)
  end

  sequence :somleng_account_sid do
    SecureRandom.uuid
  end

  factory :broadcast do
    account
    channel { "voice" }
    pending

    trait :with_attached_audio do
      association :audio_file, factory: :active_storage_attachment, filename: "test.mp3"
    end

    trait :pending do
      status { :pending }
    end

    trait :stopped do
      with_beneficiary_filter
      status { :stopped }
    end

    trait :running do
      status { :running }
      with_beneficiary_filter
      started_at { Time.current }
    end

    trait :completed do
      with_beneficiary_filter
      status { :completed }
      started_at { Time.current }
      completed_at { Time.current }
    end

    trait :with_beneficiary_filter do
      beneficiary_filter {
        {
          gender: {
            eq: "M"
          }
        }
      }
    end
  end

  factory :broadcast_beneficiary_group do
    broadcast
    beneficiary_group {  association :beneficiary_group, account: broadcast.account }
  end

  factory :beneficiary do
    account
    iso_country_code { "KH" }
    phone_number { generate(:phone_number) }

    trait :disabled do
      status { "disabled" }
    end
  end

  factory :beneficiary_group do
    account
    name { "My Group" }
  end

  factory :beneficiary_group_membership do
    beneficiary_group
    beneficiary {  association :beneficiary, account: beneficiary_group.account }
  end

  factory :batch_operation_base, class: "BatchOperation::Base" do
    account

    traits_for_enum :status, %i[preview queued running finished]

    factory :callout_population, aliases: [ :batch_operation, :broadcast_population ],
                                 class: "BatchOperation::CalloutPopulation" do
      after(:build) do |callout_population|
        callout_population.broadcast ||= build(:broadcast, account: callout_population.account)
      end
    end
  end

  factory :event do
    account
    beneficiary_created

    trait :beneficiary_created do
      transient do
        beneficiary { create(:beneficiary, account:) }
      end

      type { "beneficiary.created" }
      details {
        BeneficiaryEventSerializer.new(beneficiary).serializable_hash
      }
    end

    trait :beneficiary_deleted do
      transient do
        beneficiary { create(:beneficiary, account:) }
      end

      type { "beneficiary.deleted" }
      details {
        BeneficiaryEventSerializer.new(beneficiary).serializable_hash
      }
    end
  end

  factory :alert do
    broadcast
    beneficiary { association :beneficiary, account: broadcast.account }
    pending

    trait :pending do
      status { :pending }
    end

    trait :succeeded do
      completed_at { Time.current }
      status { :succeeded }
    end

    trait :failed do
      completed_at { Time.current }
      status { :failed }
    end
  end

  factory :delivery_attempt do
    alert
    broadcast { alert.broadcast }
    beneficiary { alert.beneficiary }
    phone_number { beneficiary.phone_number }
    status { :created }

    trait :queued do
      queued_at { Time.current }
      status { :queued }
    end

    trait :errored do
      queued_at { Time.current }
      status { :errored }
    end

    trait :initiated do
      queued_at { Time.current }
      initiated_at { Time.current }
      status { :initiated }
    end

    trait :succeeded do
      queued_at { Time.current }
      initiated_at { Time.current }
      completed_at { Time.current }
      status { :succeeded }
    end

    trait :failed do
      queued_at { Time.current }
      initiated_at { Time.current }
      completed_at { Time.current }
      status { :failed }
    end
  end

  factory :account do
    name { "PIN 1294" }

    trait :configured_for_broadcasts do
      somleng_account_sid { generate(:somleng_account_sid) }
      somleng_auth_token { generate(:auth_token) }
      alert_phone_number { "1294" }
    end
  end

  factory :user do
    account
    email
    name { "John Doe" }
    password { "secret123" }
    password_confirmation { password }
  end

  factory :access_token do
    association :resource_owner, factory: :account
    created_by { resource_owner }
  end

  factory :active_storage_attachment, class: "ActiveStorage::Blob" do
    transient do
      filename { "test.mp3" }
    end

    initialize_with do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open("#{RSpec.configuration.file_fixture_path}/#{filename}"),
        filename:
      )
    end
  end

  factory :beneficiary_address do
    beneficiary
    iso_region_code { "KH-1" }

    trait :full do
      administrative_division_level_2_code { "0102" }
      administrative_division_level_2_name { "Mongkol Borei" }
      administrative_division_level_3_code { "010201" }
      administrative_division_level_3_name { "Banteay Neang" }
      administrative_division_level_4_code { "01020101" }
      administrative_division_level_4_name { "Ou Thum" }
    end
  end

  factory :import do
    beneficiaries
    user
    account { user.account }
    status { :processing }

    trait :beneficiaries do
      resource_type { "Beneficiary" }

      association :file, factory: :active_storage_attachment, filename: "beneficiaries.csv"
    end
  end
end
