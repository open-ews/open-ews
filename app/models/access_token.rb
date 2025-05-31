class AccessToken < Doorkeeper::AccessToken
  belongs_to :account, foreign_key: :resource_owner_id
end
