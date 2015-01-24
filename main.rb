require 'redis'
require './worker'

Redis 
redis = Redis.new

worker = Worker.new()
worker.addJob('getGoogle', 'https://www.google.fr')
worker.addJob('getRedis','http://www.redis.io')
worker.addJob('getEpsi', 'http://www.epsi.fr')
worker.addJob('getLesjoiesDuCode', 'http://lesjoiesducode.fr')
