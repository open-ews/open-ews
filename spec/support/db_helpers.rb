module DBHelpers
  def autovacuum_analyze
    ApplicationRecord.connection.execute("ANALYZE")
  end
end

RSpec.configure do |config|
  config.include DBHelpers
end
