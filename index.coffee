util = require 'util'
EventEmitter = require('events').EventEmitter
AMQPStats = require 'amqp-stats'


module.exports = class RabbitMqPlugin extends EventEmitter
	constructor: (@config) ->
		@enabled = yes
		@checkedQueues = {}
		@init()
		sleepTime = @config.sleepTime || 10
		@delay=parseInt(sleepTime)*1000
	init: () =>
		existsDefaultHost = if @config.defaultHost then yes else no
		for queue,index in @config.queues
			if !queue.host and existsDefaultHost isnt yes
				throw new Exception("Bad queue configuration")
			
			host = queue.host || @config.defaultHost
			
			if !@checkedQueues[host]
				@checkedQueues[host] = []
			@checkedQueues[host].push(queue.name)

	getPluginName: ()->
		return "RabbitMqPlugin"
	open: ()->
		@stats = new AMQPStats(@config.server)
		@emit 'ready'
		@check()
	stop: ()->
		@enabled = no
	close: ()->
		@stop()
	checkDone: (newValue)=>
		if	newValue.length is @config.queues.length
			@emit 'new-value', newValue
			setTimeout(@check, @delay) if @enabled is yes
	check: ()=>
		newValue = []
		for host of @checkedQueues
			@stats.getQueuesForVHost host, (err,res,data) =>
				if err
					@emit 'error', err
				for index,queue of data
					if queue.name in @checkedQueues[host]
						v =
							name: "#{host}#{queue.name}"
							value: queue.message_stats.ack_details.rate

						newValue.push(v)
						@checkDone(newValue)
