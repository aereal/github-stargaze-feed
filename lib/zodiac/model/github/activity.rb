module Zodiac
  module Model
    module GitHub
      class Activity < ::Struct.new(:entry_id, :published, :updated, :title, :alternate_link, :author, :thumbnail, :event_type)
        class Thumbnail < ::Struct.new(:width, :height, :url)
        end

        def self.from_node(node)
          self.new.tap {|this|
            this.entry_id = node.css('id').text
            this.published = node.css('published').text
            this.updated = node.css('updated').text
            this.title = node.css('title').text

            _thumbnail = node.xpath('media:thumbnail')
            this.thumbnail = Thumbnail.new(
              _thumbnail.attr('width').text,
              _thumbnail.attr('height').text,
              _thumbnail.attr('url').text,
            )
            content_lines = node.css('content').text.each_line
            this.event_type = content_lines.first[/\A<!-- (\w+) -->/, 1].intern
          }
        end

        def watch?
          self.event_type == :watch
        end

        class Watch < ::Struct.new(*Activity.members, :actor, :object_repo, :description, :language, :open_issues_count, :stargazers_count)
          def self.from_activity(activity)
            actor, _, object_repo = activity.title.split(/\s+/)
            merged = activity.to_h.merge(actor: actor, object_repo: object_repo)
            new(*merged.values_at(*self.members))
          end

          # embed from API response
          def load!(repo)
            self.tap {|this|
              this.description = repo.description
              this.language = repo.language
              this.open_issues_count = repo.open_issues_count
              this.stargazers_count = repo.stargazers_count
            }
          end
        end
      end
    end
  end
end
