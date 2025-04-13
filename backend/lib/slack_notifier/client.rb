# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module SlackNotifier
  class Client
    class << self
      def notify_metric_change(metric, old_value, new_value, z_score)
        return if ENV.fetch("SLACK_WEBHOOK_URL", nil).blank?

        z_score.positive? ? "increase" : "decrease"
        message = {
          text: ":rotating_light: Metric Anomaly Detection :rotating_light:",
          icon_emoji: ":alert:",
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "*Statistical anomaly in metric value detected*"
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
                  text: "*Previous value:*\n#{if old_value.is_a?(MetricValue)
                                                old_value.value_with_unit(metric.prefix_unit)
                                              else
                                                (metric.prefix_unit ? "#{metric.unit}#{old_value.to_f.to_fs(:delimited)}" : "#{old_value.to_f.to_fs(:delimited)}#{metric.unit}")
                                              end}"
                },
                {
                  type: "mrkdwn",
                  text: "*Current value:*\n#{if new_value.is_a?(MetricValue)
                                               new_value.value_with_unit(metric.prefix_unit)
                                             else
                                               (metric.prefix_unit ? "#{metric.unit}#{new_value.to_f.to_fs(:delimited)}" : "#{new_value.to_f.to_fs(:delimited)}#{metric.unit}")
                                             end}"
                },
                {
                  type: "mrkdwn",
                  text: "*Anomaly score:*\n#{z_score&.round(2)} σ"
                }
              ]
            }
          ]
        }

        send_to_slack(message)
      end

      private

      def send_to_slack(message)
        uri = URI.parse(ENV.fetch("SLACK_WEBHOOK_URL", nil))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request.body = message.to_json

        http.request(request)
      end
    end
  end
end
