class FeatureFlag
  PERMISSIONS = {
    1 => [ :alerts ],
    2 => [ :alerts, :alert_approval ],
    1297 => [ :alerts ],
    1198 => [ :alerts ],
    1300 => [ :alerts ],
    1301 => [ :alerts, :alert_approval ],
    1331 => [ :alerts ],
    1332 => [ :alerts ],
    1495 => [ :alerts ],
    1693 => [ :alerts, :alert_approval ],
    1694 => [ :alerts, :alert_approval ],
    1695 => [ :alerts, :alert_approval ]
  }

  class << self
    def enabled_for?(user, flag)
      PERMISSIONS.fetch(user.id, []).include?(flag)
    end
  end
end
