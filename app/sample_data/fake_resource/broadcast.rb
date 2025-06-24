module FakeResource
  class Broadcast
    include ActiveModel::Model
    include ActiveModel::Attributes

    extend Enumerize

    attribute :id
    attribute :operator
    attribute :channel
    attribute :status
    attribute :progress_percentage, :integer, default: 0
    attribute :created_at
    attribute :started_at
    attribute :completed_at

    enumerize :channel, in: [ :sms ]
    enumerize :status, in: [ :pending, :in_progress, :completed ]

    def model_name
      ActiveModel::Name.new(self, nil, "Broadcast")
    end

    class << self
      def all
        @broadcasts ||= [
          Broadcast.new(
            id: "4",
            operator: "Jazz",
            channel: "sms",
            status: "pending",
            progress_percentage: 0,
          ),
          Broadcast.new(
            id: "3",
            operator: "Ufone",
            channel: "sms",
            status: "in_progress",
            progress_percentage: 75,
            started_at: 23.hours.ago
          ),
          Broadcast.new(
            id: "2",
            operator: "Zong",
            channel: "sms",
            status: "in_progress",
            progress_percentage: 90,
            started_at: 23.hours.ago
          ),
          Broadcast.new(
            id: "1",
            operator: "Telenor",
            channel: "sms",
            status: "completed",
            progress_percentage: 100,
            started_at: 23.hours.ago,
            completed_at: 22.hours.ago
          )
        ]
      end
    end
  end
end
