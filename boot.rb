require 'logger'
require 'mongoid'

logger = Logger.new('log/realtions.log')
logger.level = Logger::DEBUG


Mongoid.load!("mongoid.yml", :development)
Mongoid.logger = logger
Moped.logger = logger
