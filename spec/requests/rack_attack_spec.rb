# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rack::Attack, type: :request do
  describe "scanner probes" do
    it "forbids requests for secret files" do
      with_rack_attack_cache do
        get "/.env", env: {"REMOTE_ADDR" => "203.0.113.1"}

        expect(response).to have_http_status(:forbidden)
      end
    end

    it "forbids requests for PHP scripts" do
      with_rack_attack_cache do
        get "/wp-login.php", env: {"REMOTE_ADDR" => "203.0.113.1"}

        expect(response).to have_http_status(:forbidden)
      end
    end

    it "bans the probing IP from the rest of the site" do
      with_rack_attack_cache do
        get "/.git/config", env: {"REMOTE_ADDR" => "203.0.113.1"}
        get credits_path, env: {"REMOTE_ADDR" => "203.0.113.1"}

        expect(response).to have_http_status(:forbidden)
      end
    end

    it "keeps serving other IPs" do
      with_rack_attack_cache do
        get "/.env", env: {"REMOTE_ADDR" => "203.0.113.1"}
        get credits_path, env: {"REMOTE_ADDR" => "203.0.113.2"}

        expect(response).to have_http_status(:ok)
      end
    end

    it "lets well-known URIs through" do
      with_rack_attack_cache do
        get "/.well-known/assetlinks.json",
          env: {"REMOTE_ADDR" => "203.0.113.1"}

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  def with_rack_attack_cache
    original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rack::Attack.cache.store = original_store
  end
end
