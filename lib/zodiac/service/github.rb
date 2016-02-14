require 'faraday/rack_builder'
require 'octokit'
require 'yaml'

require 'zodiac/middleware/cache'

module Zodiac

  module Service
    module GitHub
      def self.new(host, with_cache: false, logging: false)
        hub_config = YAML.load_file(File.expand_path('~/.config/hub'))
        github_config = hub_config.fetch(host, []).first or abort 'No configuration found'
        Octokit::Client.new(access_token: github_config.fetch('oauth_token')).tap do |this|
          stack = Faraday::RackBuilder.new do |builder|
            builder.use Zodiac::Middleware::Cache if with_cache
            builder.use Zodiac::Middleware::NeverExpire if with_cache
            builder.response :logger if logging
            builder.adapter Faraday.default_adapter
          end
          this.middleware = stack
        end
      end
    end
  end
end
