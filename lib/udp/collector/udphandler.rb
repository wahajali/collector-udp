require 'msgpack'
require 'yajl'
module Udp
  module Collector
    class UDPHandler < EM::Connection
      def receive_data(data)
        data = MessagePack.unpack(data)

        File.open('logs/data.logs', 'a') do |file| 
          file.write(data.to_s + "\n") 
        end

        body = Yajl::Encoder.encode(process_data(data))
        http = ConnectionPool.instance.get_connection.post body: body, keepalive: true, headers: {"Content-type" => "application/json"}

        http.errback do
          ::Collector::Config.logger.warn('http.response.failed to kairos: ' + http.error.to_s)
        end

=begin
        http.callback do
          #NOTE: do nothing. why waste time logging success?
          ::Collector::Config.logger.warn('http.response.success' + http.error)
        end
=end
      end

      TAGS_META = %W[name display_name host].freeze
      TAGS = %W[name unit type].freeze

      def process_data(data)
        #data["unit"] = "percentage" if data["unit"] == "%"
        tags = {}
        TAGS_META.each do |t|
          tags[t] = data["resource_metadata"][t] unless data["resource_metadata"][t].nil?
        end

        TAGS.each do |t|
          tags[t] = data[t]
        end

        publish_data = {}
        publish_data[:name] = data["resource_id"]
        publish_data[:timestamp] = (Time.parse(data["timestamp"]).to_f * 1000).to_i
        publish_data[:value] = data["volume"]
        publish_data[:tags] = tags
        publish_data
      end
    end
  end
end
