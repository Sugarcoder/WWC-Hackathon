module Sidekiq
  module Middleware
    module Server
      class TaggedLogger

        def call(worker, item, queue)
          tag = "#{worker.class.to_s} #{SecureRandom.hex(12)}"
          ::Rails.logger.tagged(tag) do
            job_info = "Start at #{Time.now.to_default_s}: #{item.inspect}"
            ::Rails.logger.info(job_info)
            yield
          end
        end

      end
    end
  end
end

REDIS_URL = ENV["REDIS_DB_URL"] || 'redis://127.0.0.1:6379/1'

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URL, size: 3 }
#  Rails.logger = Sidekiq::Logging.logger
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::TaggedLogger
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => REDIS_URL, :size => 1 }
end