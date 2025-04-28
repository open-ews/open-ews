class AddDetailsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column(:events, :details, :jsonb, null: false, default: {})
  end
end
