require 'active_support/cache'
require 'faraday-http-cache'
require 'logger'

module Zodiac
  module Middleware
    class Cache < ::Faraday::HttpCache
      def initialize(app, options = {})
        cache_store = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
        options.merge!(
          store: cache_store,
          logger: Logger.new($stderr),
          serializer: Marshal,
          shared_cache: false
        )
        super(app, options)
      end
    end

    class NeverExpire < ::Faraday::Middleware
      def initialize(app)
        super
      end

      def call(env)
        res = @app.call(env)
        res.headers['max-age'] = 86400 * 365 * 10
        res.headers["Expires"] = "Thu, 14 Nov 2024 01:44:36 GMT"
        res
      end
    end
  end
end
