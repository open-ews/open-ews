require "rails_helper"

module V1
  RSpec.describe BroadcastRequestSchema, type: :request_schema do
    it "validates the channel" do
      account = create(:account, supported_channels: [ "voice_call" ])

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call"
              }
            }
          },
          options: {
            account:
          }
        )
      ).to have_valid_field(:data, :attributes, :channel)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice"
              }
            }
          },
          options: {
            account:
          }
        )
      ).to have_valid_field(:data, :attributes, :channel)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "text_message"
              }
            }
          },
          options: {
            account:
          }
        )
      ).not_to have_valid_field(:data, :attributes, :channel, error_message: "is not supported")
    end

    it "validates the beneficiary filter" do
      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {},
              relationships: {
                beneficiary_groups: {}
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(
          input_params: {
            data: { attributes: {} }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)
    end

    it "validates the beneficiary groups" do
      account = create(:account)
      other_beneficiary_group = create(:beneficiary_group)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: 11.times.map { |index| { id: index + 1, type: "beneficiary_group" } }
                }
              }
            }
          },
          options: {
            account:
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data, error_message: "size cannot be greater than 10")

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
            account:
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)
    end

    it "validates the status" do
      account = create(:account)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call",
                status: "running"
              }
            }
          },
          options: {
            account:
          }
        )
      ).not_to have_valid_schema(error_message: "Account not configured")
    end

    it "validates voice and audio broadcasts" do
      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call",
                audio_url: "https://www.example.com/test.mp3"
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :audio_url)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :audio_url, error_message: "is missing")

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "audio"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :audio_url, error_message: "is missing")

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "text_message",
                audio_url: "https://www.example.com/test.mp3"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :audio_url, error_message: "is not allowed")
    end

    it "validates message broadcasts" do
      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "text_message",
                message: "Test message"
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :message)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "text_message"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :message, error_message: "is missing")

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice_call",
                message: "Test message"
              }
            }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :message, error_message: "is not allowed")
    end

    it "handles postprocessing" do
      schema = validate_schema(
        input_params: {
          data: {
            attributes: {
              channel: "text_message",
              message: "Test message"
            }
          }
        }
      )

      expect(schema.output).to eq(
        channel: "text_message",
        message: "Test message",
        beneficiary_group_ids: [],
        created_via: :api
      )
    end

    def validate_schema(input_params:, options: {})
      BroadcastRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
