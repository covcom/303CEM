
'use strict'

const http = require('http')
const defaultPort = 8080
const statusOK = 200
const server = http.createServer(function(req, res) {
	res.writeHead(statusOK)
	res.end('Goodbye World!')
})
server.listen(process.env.PORT || defaultPort)
