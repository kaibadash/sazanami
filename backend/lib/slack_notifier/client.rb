# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module SlackNotifier
  class Client
    class << self
      def notify_metric_change(metric, old_value, new_value, change_percent)
        return if webhook_url.blank?
        return unless change_percent.abs >= threshold_percent

        direction = change_percent.positive? ? "increase" : "decrease"
        message = {
          text: ":rotating_light: Metric Rapid Change Notification :rotating_light:",
          icon_emoji: ":alert:",
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "*Rapid #{direction} in metric value detected*"
              }
            },
            {
              type: "section",
              fields: [
                {
                  type: "mrkdwn",
                  text: "*Category:*\n#{metric.category.name}"
                },
                {
                  type: "mrkdwn",
                  text: "*Metric:*\n#{metric.label}"
                },
                {
                  type: "mrkdwn",
                  text: "*Previous value:*\n#{old_value.value_with_unit(metric.prefix_unit)}"
                },
                {
                  type: "mrkdwn",
                  text: "*Current value:*\n#{new_value.value_with_unit(metric.prefix_unit)}"
                },
                {
                  type: "mrkdwn",
                  text: "*Change rate:*\n#{change_percent.round(2)}%"
                }
              ]
            }
          ]
        }

        send_to_slack(message)
      end

      private

      def send_to_slack(message)
        uri = URI.parse(webhook_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request.body = message.to_json

        http.request(request)
      end

      def webhook_url
        ENV.fetch("SLACK_WEBHOOK_URL", nil)
      end

      def threshold_percent
        ENV.fetch("METRIC_CHANGE_THRESHOLD", 10).to_f
      end
    end
  end
end
