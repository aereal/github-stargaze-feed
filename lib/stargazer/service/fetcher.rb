require 'active_support/cache'
require 'faraday'
require 'faraday-http-cache'
require 'logger'

module Stargazer
  module Service
    module Fetcher
      def self.new(logger = Logger.new($stderr))
        opts = {
            headers: {
            'User-Agent' => "#{File.basename(`git rev-parse --show-toplevel`.strip)}/#{`git rev-parse --short HEAD`.strip}"
          },
        }
        cache_store = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
        Faraday.new(opts) do |c|
          c.use :http_cache, store: cache_store, logger: logger, serializer: Marshal
          c.adapter Faraday.default_adapter
        end
      end
    end
  end
end
