class AddBeneficiaryFilterAndChannelToCallouts < ActiveRecord::Migration[8.0]
  def change
    add_column :callouts, :channel, :string, null: false
    add_column :callouts, :beneficiary_filter, :jsonb, null: false, default: {}
  end
end
