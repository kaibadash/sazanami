# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module SlackNotifier
  class Client
    class << self
      def notify_metric_change(metric, old_value, new_value, z_score)
        return if webhook_url.blank?

        direction = z_score.positive? ? "increase" : "decrease"
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
                  text: "*Previous value:*\n#{format_value(old_value, metric)}"
                },
                {
                  type: "mrkdwn",
                  text: "*Current value:*\n#{format_value(new_value, metric)}"
                },
                {
                  type: "mrkdwn",
                  text: "*Change rate:*\n#{change_percent.round(2)}% (#{direction})"
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

      def format_value(value, metric)
        if value.is_a?(MetricValue)
          value.value_with_unit(metric.prefix_unit)
        else
          formatted_value = value.to_f.to_fs(:delimited)
          metric.prefix_unit ? "#{metric.unit}#{formatted_value}" : "#{formatted_value}#{metric.unit}"
        end
      end
    end
  end
end
