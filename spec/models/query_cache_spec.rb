require "rails_helper"

RSpec.describe QueryCache do
  it "handles basic query caching" do
    cache = QueryCache.new(store: build_cache_store)
    cache_misses = 0
    params = { foo: "bar" }

    2.times do
      cache.fetch(params) do
        cache_misses += 1
      end
    end

    expect(cache_misses).to eq(1)
  end

  it "handles scoping with scope keys" do
    cache = QueryCache.new(store: build_cache_store)
    cache_misses = 0
    params = { foo: "bar" }

    2.times do
      cache.fetch(params, scope_keys: [ "scope1" ]) do
        cache_misses += 1
      end
    end

    expect(cache_misses).to eq(1)

    cache.fetch(params, scope_keys: [ "scope2" ]) do
      cache_misses += 1
    end

    expect(cache_misses).to eq(2)
  end

  it "handles sorting query params" do
    cache = QueryCache.new(store: build_cache_store)
    cache_misses = 0

    params1 = {
      foo: [ { foo: "bar", baz: "foo" }, { foo: "bar", bar: "baz" } ],
      baz: "baz",
      bar: {
        baz: "baz",
        bar: "bar"
      }
    }

    params2 = {
      bar: {
        bar: "bar",
        baz: "baz"
      },
      baz: "baz",
      foo: [ { baz: "foo", foo: "bar" }, { bar: "baz", foo: "bar" } ]
    }

    cache.fetch(params1) do
      cache_misses += 1
    end

    cache.fetch(params2) do
      cache_misses += 1
    end

    expect(cache_misses).to eq(1)
  end

  it "handles cache expiration" do
    cache = QueryCache.new(store: build_cache_store, default_expires_in: 0.seconds)
    cache_misses = 0
    params = { foo: "bar" }

    2.times do
      cache.fetch(params) do
        cache_misses += 1
      end
    end

    expect(cache_misses).to eq(2)
  end

  def build_cache_store
    ActiveSupport::Cache::MemoryStore.new
  end
end
