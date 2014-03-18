module Collector
  # Singleton config used throughout
  class Config
    class << self
      attr_accessor :kairos_host, :port, :connection_pool

      def logger
        raise "logger was used without being configured" unless @logging_configured
        @logger 
      end

      def setup_logging(config={})
        @logger = Logger.new(config["file"])
        @logging_configured = true
        logger.info("collector.started")
      end

      # Configures the various attributes
      #
      # @param [Hash] config the config Hash
      def configure(config)
        setup_logging(config["logging"])

        @kairos_host = config["kairos_host"]

        @port = config["port"]
        @connection_pool = config["connection_pool"]
      end
    end
  end
end
