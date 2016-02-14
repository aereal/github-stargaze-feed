require 'sinatra/base'
require 'erubis'
require 'nokogiri'
require 'parallel'
require 'time'

require 'zodiac/service/fetcher'
require 'zodiac/service/github'
require 'zodiac/service/github/activity_feed'

module Zodiac
  class Web < ::Sinatra::Base
    enable :logging
    set :views, File.join(`git rev-parse --show-toplevel`.strip, 'templates')
    set :api_concurrency, 4

    get '/@my/activities' do
      feed_url = params['url'] or halt 400, 'No url given'

      client = Zodiac::Service::Fetcher.new
      res = client.get(feed_url)
      unless res.success?
        halt 400, 'fail to fetch'
      end
      feed = Nokogiri.XML(res.body)
      activities = Zodiac::Service::GitHub::ActivityFeed.parse(feed)

      octokit = Zodiac::Service::GitHub.new('github.com', with_cache: true)

      Parallel.each(activities, in_threads: settings.api_concurrency) do |a|
        a.load!(octokit.repo(a.object_repo))
      end

      feed = activities.
        group_by(&:object_repo).
        each_entry.map {|repo_name, gazers| [gazers.first, gazers] }.
        sort_by {|(repo, _)| Time.parse(repo.published).to_i }

      erb :activities, locals: { feed: feed }
    end
  end
end
