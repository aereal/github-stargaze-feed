require 'zodiac/model/github/activity'

module Zodiac
  module Service
    module GitHub
      module ActivityFeed
        def self.parse(feed)
          entries = feed.css('entry')
          activities = entries.map {|e| Zodiac::Model::GitHub::Activity.from_node(e) }
          watch_activities = activities.select(&:watch?)
          watches = watch_activities.map {|wa| Zodiac::Model::GitHub::Activity::Watch.from_activity(wa) }
          watches
        end
      end
    end
  end
end
