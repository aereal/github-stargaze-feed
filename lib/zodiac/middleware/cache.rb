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
  end
end
