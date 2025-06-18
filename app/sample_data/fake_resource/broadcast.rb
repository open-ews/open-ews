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
          ),
          Broadcast.new(
            id: "2",
            operator: "Zong",
            channel: "sms",
            status: "in_progress",
            progress_percentage: 90,
          ),
          Broadcast.new(
            id: "1",
            operator: "Telenor",
            channel: "sms",
            status: "completed",
            progress_percentage: 100
          )
        ]
      end

      def find(id)
        all.find(-> { raise(ActiveRecord::RecordNotFound) }) { it.id == id }
      end
    end
  end
end
