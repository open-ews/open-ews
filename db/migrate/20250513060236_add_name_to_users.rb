class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    remove_column :users, :metadata, :jsonb, default: {}, null: false

    reversible do |dir|
      dir.up do
        User.find_each do |user|
          user.update_columns(name: user.email.split("@").first.split("+").first.gsub(".", " ").humanize)
        end
      end
    end

    change_column_null :users, :name, false
  end
end
