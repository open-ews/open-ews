class FeatureFlag
  PERMISSIONS = {
    1 => [ :alerts ],
    1297 => [ :alerts ],
    1198 => [ :alerts ],
    1300 => [ :alerts ]
  }

  class << self
    def enabled_for?(user, flag)
      PERMISSIONS.fetch(user.id, []).include?(flag)
    end
  end
end
