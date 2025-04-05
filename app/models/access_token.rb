class AccessToken < Doorkeeper::AccessToken
  belongs_to :resource_owner, class_name: "Account"
  belongs_to :created_by,     class_name: "Account"
end
