require 'redis'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'

class Worker
	def  storeJob(serializedJob)
		redis = Redis.new
		redis.lpush("jobsList", serializedJob)
	end

	def serializeJobInJSON()
			return {'jobName' => @name, 'action' => @action}.to_json
	end

	def addJob(name,action)
		@name = name
		@action = action
		serializedJob = self.serializeJobInJSON()
		self.storeJob(serializedJob)
	end
end

class CrawlerWorker < Worker
	def start()
		treatedjob = 0
		while true do
			GetNumberOfWaitingJobs()
			GetNumberOfTreatedJobs(treatedjob)

			redis = Redis.new
			currentJob = redis.rpop("jobsList")
			if !currentJob.nil?
				treatedjob = treatedjob + 1
				parsedJob = JSON.parse(currentJob)
				currentJobName = parsedJob["jobName"]
				currentjobAction = parsedJob["action"]

				puts "#{currentJobName} is running"

				DisplayWebSiteTitle(currentjobAction)

			end
			sleep 5
		end
	end

	def DisplayWebSiteTitle(url)
		result = Net::HTTP.get_response(URI.parse(url)).body
		doc = Nokogiri::HTML(result)

		page = {}

		doc.xpath('//title').each do |title|
			page[:title] = title.content.split(" ")[0]
			puts "The title of this Website is : #{title.content.split(" ")[0]}"
		end

		doc.xpath("//meta[@name='description']/@content").each do |description|
			if !description.nil?
				page[:description] = description.content
			else
				page[:description] = " "
			end
		end

		doc.xpath("//meta[@name='keywords']/@content").each do |keywords|
			if !keywords.nil?
				keywords = keywords.content.split(",").to_a
				page[:keywords] = keywords
			else
				page[:keywords] = " "
			end
		end
		page = page.to_json
		`curl -XPOST localhost:9200/web/pages -d '#{page}'`
	end

	def GetNumberOfWaitingJobs()
		redis = Redis.new
		waitingJobs = redis.lrange "jobsList", 0, -1
		puts "There is #{waitingJobs.length} jobs wainting to be treated."
	end

	def GetNumberOfTreatedJobs(treatedjob)
		puts "#{treatedjob} job(s) treated."
	end
end