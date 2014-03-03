from HttpServer import HttpServer

dbFile = 'samples.db'
storeDir = 'samples'

host = '' # Listen on all IP addresses
port = 8082


server = HttpServer((host, port), dbFile, storeDir)
print "started HTTP server on http://%s:%s/" % (host, port)
try:
    server.serve_forever()
finally:
    server.socket.close()   
