class QueryCache
  attr_reader :store, :default_expires_in

  def initialize(store: Rails.cache, default_expires_in: 1.day)
    @store = store
    @default_expires_in = default_expires_in
  end

  def fetch(params, scope_keys: [], **)
    store.fetch(cache_key(params, scope_keys:), expires_in: default_expires_in, **) do
      yield
    end
  end

  private

  def cache_key(params, scope_keys:)
    [
      "query_cache",
      *Array(scope_keys).sort,
      sha256_params(params)
    ].join(":")
  end

  def sha256_params(params)
    Digest::SHA256.hexdigest(deep_sort(params).to_json)
  end

  def deep_sort(obj)
    case obj
    when Hash
      obj.sort.to_h.transform_values { |v| deep_sort(v) }
    when Array
      obj.map { |v| deep_sort(v) }
    else
      obj
    end
  end
end

#         Rails.cache.fetch("expensive_query_key", expires_in: 10.minutes) do
#   Model.where(...).to_a
# end
