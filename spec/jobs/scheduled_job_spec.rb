require "rails_helper"

RSpec.describe ScheduledJob do
  it "initializes delivery attempts" do
    account = create(:account, delivery_attempt_queue_limit: 1)

    low_priority_delivery_attempt = create(
      :delivery_attempt,
      notification: create(
        :notification,
        broadcast: create(:broadcast, :running, account:),
        priority: 1
      )
    )
    high_priority_delivery_attempt = create(
      :delivery_attempt,
      notification: create(
        :notification,
        broadcast: create(:broadcast, :running, account:)
      )
    )
    delivery_attempt_from_running_broadcast = create(
      :delivery_attempt,
      notification: create(
        :notification,
        broadcast: create(:broadcast, :running, account:)
      )
    )
    delivery_attempt_from_stopped_broadcast = create(
      :delivery_attempt,
      notification: create(
        :notification,
        broadcast: create(:broadcast, :stopped, account:)
      )
    )
    queued_delivery_attempt = create(
      :delivery_attempt,
      :queued,
      notification: create(
        :notification,
        broadcast: create(:broadcast, :running, account:)
      )
    )

    ScheduledJob.perform_now

    expect(high_priority_delivery_attempt.reload.status).to eq("queued")
    expect(low_priority_delivery_attempt.reload.status).to eq("created")
    expect(delivery_attempt_from_stopped_broadcast.reload.status).to eq("created")
    expect(queued_delivery_attempt.reload.status).to eq("queued")

    expect(InitiateDeliveryAttemptJob).to have_been_enqueued.exactly(:once)
    expect(InitiateDeliveryAttemptJob).to have_been_enqueued.with(high_priority_delivery_attempt)
  end

  it "fetches in progress call statuses" do
    account = create(:account)

    in_progress_delivery_attempt = create(
      :delivery_attempt,
      :initiated,
      initiated_at: 10.minutes.ago,
      notification: create(
        :notification,
        broadcast: create(:broadcast, account:)
      )
    )

    in_progress_queued_for_fetch_expired_delivery_attempt = create(
      :delivery_attempt,
      :initiated,
      initiated_at: 10.minutes.ago,
      status_update_queued_at: 20.minutes.ago,
      notification: create(
        :notification,
        broadcast: create(:broadcast, account:)
      )
    )

    create(
      :delivery_attempt,
      :initiated,
      initiated_at: Time.current,
      notification: create(
        :notification,
        broadcast: create(:broadcast, account:)
      )
    )

    create(
      :delivery_attempt,
      :initiated,
      initiated_at: 10.minutes.ago,
      status_update_queued_at: Time.current,
      notification: create(
        :notification,
        broadcast: create(:broadcast, account:)
      )
    )

    ScheduledJob.perform_now

    expect(UpdateDeliveryAttemptStatusJob).to have_been_enqueued.exactly(:twice)
    expect(UpdateDeliveryAttemptStatusJob).to have_been_enqueued.with(in_progress_delivery_attempt)
    expect(UpdateDeliveryAttemptStatusJob).to have_been_enqueued.with(in_progress_queued_for_fetch_expired_delivery_attempt)
    expect(in_progress_delivery_attempt.reload.status_update_queued_at).to be_present
  end
end
