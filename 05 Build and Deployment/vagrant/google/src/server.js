
'use strict'
console.log('starting')
const http = require('http')
const defaultPort = 8080
const statusOK = 200
const server = http.createServer(function(req, res) {
	console.log('incoming request')
	res.writeHead(statusOK)
	res.end('Goodbye World!')
})
console.log(`PORT environment var: ${process.env.PORT}`)
server.listen(process.env.PORT || defaultPort)
