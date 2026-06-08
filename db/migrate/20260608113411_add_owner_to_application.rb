# frozen_string_literal: true

class AddOwnerToApplication < ActiveRecord::Migration[8.1]
  def change
    add_column :oauth_applications, :owner_type, :string, null: false
    add_index :oauth_applications, [:owner_id, :owner_type]
  end
end
