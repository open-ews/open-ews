class CreateWebhookEndpointsAndRequestLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :webhook_endpoints do |t|
      t.references :oauth_application, null: false, foreign_key: { to_table: :oauth_applications }
      t.string :url, null: false
      t.string :signing_secret, null: false
      t.string :subscriptions, array: true, null: false
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end

    create_table :webhook_request_logs do |t|
      t.references :event, null: false, foreign_key: true
      t.references :webhook_endpoint, null: false, foreign_key: true
      t.string :url, null: false
      t.string :http_status_code, null: false
      t.boolean :failed, null: false
      t.jsonb :payload, null: false, default: {}
      t.timestamps
    end
  end
end
