require './worker.rb'
require 'redis'

crawler = CrawlerWorker.new
crawler.start()