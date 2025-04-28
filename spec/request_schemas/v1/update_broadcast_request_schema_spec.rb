require "rails_helper"

module V1
  RSpec.describe UpdateBroadcastRequestSchema, type: :request_schema do
    it "validates the audio_url" do
      broadcast = create(:broadcast, status: :pending)
      started_broadcast = create(:broadcast, status: :running)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "invalid-url" } } }, options: { resource: broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(input_params: { data: { attributes: { audio_url: "http://example.com/sample.mp3" } } }, options: { resource: started_broadcast })
      ).not_to have_valid_field(:data, :attributes, :audio_url)
    end

    it "validates the beneficiary_filter" do
      broadcast = create(:broadcast, status: :pending)
      started_broadcast = create(:broadcast, status: :running)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(input_params: { data: { attributes: { beneficiary_filter: { status: { eq: "active" } } } } }, options: { resource: broadcast })
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(input_params: { data: { attributes: { beneficiary_filter: { status: { eq: "active" } } } } }, options: { resource: started_broadcast })
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)
    end

    it "validates the status" do
      account = create(:account)
      errored_broadcast = create(:broadcast, status: :errored, account:)
      pending_broadcast = create(:broadcast, status: :pending, account:)
      running_broadcast = create(:broadcast, status: :running, account:)
      stopped_broadcast = create(:broadcast, status: :stopped, account:)
      completed_broadcast = create(:broadcast, status: :completed, account:)
      queued_broadcast = create(:broadcast, status: :queued, account:)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "foobar" } } }, options: { resource: pending_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: {} } }, options: { resource: pending_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "pending" } } }, options: { resource: running_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: running_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: stopped_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: completed_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: completed_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "queued" } } }, options: { resource: pending_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: errored_broadcast })
      ).to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "stopped" } } }, options: { resource: errored_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "queued" } } }, options: { resource: errored_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(input_params: { data: { attributes: { status: "running" } } }, options: { resource: queued_broadcast })
      ).not_to have_valid_field(:data, :attributes, :status)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice",
                status: "running"
              }
            }
          },
          options: {
            account:,
            resource: pending_broadcast
          }
        )
      ).not_to have_valid_schema(error_message: "Account not configured")
    end

    it "validates the beneficiary groups" do
      account = create(:account)
      broadcast = create(:broadcast, :pending, account:)
      running_broadcast = create(:broadcast, :running, account:)
      beneficiary_group = create(:beneficiary_group, account:)
      other_beneficiary_group = create(:beneficiary_group)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: other_beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
            resource: running_broadcast
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)
    end

    it "handles post processing" do
      pending_broadcast = create(:broadcast, status: :pending)
      errored_broadcast = create(:broadcast, status: :errored)

      result = validate_schema(
        input_params: {
          data: {
            id: pending_broadcast.id,
            attributes: {
              status: "running",
              audio_url: "http://example.com/sample.mp3"
            }
          }
        },
        options: { resource: pending_broadcast }
      ).output

      expect(result).to include(
        desired_status: :queued,
        audio_url: "http://example.com/sample.mp3"
      )

      result = validate_schema(
        input_params: {
          data: {
            id: errored_broadcast.id,
            attributes: {
              status: "running",
              audio_url: "http://example.com/sample.mp3"
            }
          }
        },
        options: { resource: errored_broadcast }
      ).output

      expect(result).to include(
        desired_status: :queued,
        audio_url: "http://example.com/sample.mp3"
      )
    end

    def validate_schema(input_params:, options: {})
      UpdateBroadcastRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
