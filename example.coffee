util = require 'util'
Plugin = require './index'


config = 
	server:
		username: "username"
		password: "password"
		hostname: "localhost:55672"
	sleepTime: 10
	defaultHost: "/"
	queues:[
		{
			name: "queue-1"
		},
		{
			name: "queue-2"
		}

	]


plugin = new Plugin(config)


i = 0

plugin.on 'new-value', (value) =>
	util.log "New value:"
	util.log util.inspect value

	if i++ > 10
		#ONLYT 10 interation and after this stop
		plugin.stop()


plugin.open()
