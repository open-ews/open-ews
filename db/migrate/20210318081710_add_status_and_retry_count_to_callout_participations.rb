class AddStatusAndRetryCountToCalloutParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :callout_participations, :answered, :boolean, default: false, null: false, index: true
    add_column :callout_participations, :phone_calls_count, :integer, null: false, default: 0, index: true

    remove_column :phone_calls, :create_batch_operation_id, :bigint
    remove_column :phone_calls, :queue_batch_operation_id, :bigint
    remove_column :phone_calls, :queue_remote_fetch_batch_operation_id, :bigint
    remove_column :phone_calls, :remote_request_params
    add_index :phone_calls, :created_at
    add_index :phone_calls, :remotely_queued_at
    add_index :phone_calls, :msisdn
    add_index :phone_calls, :status
    add_index :callouts, :status
    add_index :contacts, :created_at
    add_index :contacts, :updated_at
  end
end
