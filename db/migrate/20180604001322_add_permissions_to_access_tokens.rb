class AddPermissionsToAccessTokens < ActiveRecord::Migration[5.2]
  def change
    add_column(
      :oauth_access_tokens,
      :permissions,
      :bigint,
      default: 0,
      null: false
    )
  end
end
