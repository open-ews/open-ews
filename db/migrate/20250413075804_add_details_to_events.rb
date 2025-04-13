class AddDetailsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column(:events, :details, :jsonb, null: false, default: {})

    reversible do |dir|
      dir.up do
        Event.where(type: "beneficiary.created").delete_all
      end
    end
  end
end
