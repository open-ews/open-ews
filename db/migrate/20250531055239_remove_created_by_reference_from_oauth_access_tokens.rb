class RemoveCreatedByReferenceFromOauthAccessTokens < ActiveRecord::Migration[8.0]
  def change
    remove_reference :oauth_access_tokens, :created_by, foreign_key: { to_table: :accounts }, null: false
  end
end
