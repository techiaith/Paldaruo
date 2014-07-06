#!python
#encoding: utf-8
import os, re, traceback, BaseHTTPServer, SocketServer, json, sys, cgi, uuid, sqlite3, random
import Metadata, Prompts

def getParam(query, name, decodeUtf8=True, required=True):
    vals = query.get(name)
    if vals is None or len(vals) == 0:
        if required:
            raise ValueError("No param %r" % name)
        return None
    val = vals[0]
    if decodeUtf8: 
        return val.decode('UTF-8')
    else:
        return val

class AuthError(Exception):
    pass

class TorfRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    
    def do_GET(self):
        htmlFile='test.html'
        print self.path;

        if self.path == '/telerau_v1.0.html':
            htmlFile='telerau_v1.0.html'            
        elif self.path != '/':
            self.send_response(404)
            self.end_headers()
            self.wfile.close()
            return
        self.send_response(200)
        self.send_header('content-type', 'text/html')
        self.end_headers()
        with open(htmlFile) as f:
            self.wfile.writelines(f)
        self.wfile.close()

    def do_POST(self):
        ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
        query = cgi.parse_multipart(self.rfile, pdict)
        try:
            response = self.getPostResponse(self.path, query)
            jsonVal = json.dumps({"response": response})
            responseCode = 200
        except Exception, ex:
            traceback.print_exc()
            jsonVal = json.dumps({"error": str(ex)})
            responseCode = 500
        self.send_response(responseCode)
        self.end_headers()
        self.wfile.write(jsonVal)
        self.wfile.close()

    def do_PUT(self):
        try:
            responseheaders = self.getPutResponse()
            responseCode = 200
        except Exception, ex:
            traceback.print_exc()
            jsonVal = json.dumps({"error": str(ex)})
            responseCode = 500
        self.send_response(responseCode)
        for key in responseheaders.keys():
            self.send_header(key,responseheaders[key])
        self.end_headers()
        self.wfile.close()

    def getPostResponse(self, path, query):
        if path == '/resetDatabase':
            raise ValueError("Refused to reset database")
            return self.resetDatabase()
        if path == '/createUser':
            return self.createUser()
        uid = getParam(query, 'uid')
        #self.checkUid(uid)
        if path == '/getMetadata':
            return self.getMetadata()
        elif path == '/saveMetadata':
            return self.saveMetadata(uid, getParam(query, 'metadata'))
        elif path == '/getOutstandingPrompts':
            shuffle = ('false' != getParam(query, 'shuffle', required=False))
            return self.getOutstandingPrompts(uid, shuffle)
        elif path == '/savePrompt':
            return self.savePrompt(uid, getParam(query, 'promptId'), getParam(query, 'file', decodeUtf8=False))
        else:
            raise ValueError("Bad path: " + path)

    def getPutResponse(self):
       if self.path == '/savePrompt':
           return self.putPrompt()
       else:
           raise ValueError("Bad path: " + path)
 
    def dbConnect(self):
        db = sqlite3.connect(self.server.dbFile)
        db.isolation_level = None
        return db

    def checkUid(self, uid):
        db = self.dbConnect()
        count = db.execute("select count(*) from users where uid=? limit 1", (uid,)).fetchone()[0]
        if count == 0:
            raise AuthError("No such uid: %r" % uid)

    def resetDatabase(self):
        if os.path.exists(self.server.dbFile):
            os.unlink(self.server.dbFile)
        db = self.dbConnect()
        db.execute("create table users (uid varchar primary key, metadata varchar)")

    def createUser(self):
        uid = str(uuid.uuid4())
        db = self.dbConnect()
        db.execute("insert into users(uid) values(?)", (uid,))
        return {'uid': uid}

    def getMetadata(self):
        return Metadata.QUESTIONS

    def saveMetadata(self, uid, metadata):
        db = self.dbConnect()
        db.execute("update users set metadata=? where uid=?", (metadata, uid))
        return {}

    def getOutstandingPrompts(self, uid, shuffle):
        if not re.match(r"^[-0-9A-Za-z_]+$", uid):
            raise ValueError("Invalid uid: %r" % uid)
        userDir = os.path.join(self.server.storeDir, uid)
        allIds = set(p["identifier"] for p in Prompts.PROMPTS)
        completedIds = set(os.path.splitext(x)[0] for x in os.listdir(userDir))
        outstandingIds = allIds - completedIds
        outstandingPrompts = [p for p in Prompts.PROMPTS if p["identifier"] in outstandingIds]
        if shuffle:
            random.shuffle(outstandingPrompts)
        return outstandingPrompts

    def savePrompt(self, uid, promptId, fileData):
        if not re.match(r"^[0-9A-Za-z_]+$", promptId):
            raise ValueError("Invalid promptId: %r" % promptId)
        if not os.path.isdir(self.server.storeDir):
            os.mkdir(self.server.storeDir)
        if not re.match(r"^[-0-9A-Za-z_]+$", uid):
            raise ValueError("Invalid uid: %r" % uid)
        userDir = os.path.join(self.server.storeDir, uid)
        if not os.path.isdir(userDir):
            os.mkdir(userDir)
        promptFile = os.path.join(userDir, promptId + '.wav')
        with open(promptFile, 'w') as f:
            f.write(fileData)

        print uid + ", " + promptId

        filename=promptId+".wav" 
        return {"uid":uid, "fileId":filename}


    def putPrompt(self):
        promptId = self.headers['promptId']
        if not re.match(r"^[0-9A-Za-z_]+$", promptId):
            raise ValueError("Invalid promptId: %r" % promptId)
        uid = self.headers['uid']
        if not re.match(r"^[-0-9A-Za-z_]+$", uid):
            raise ValueError("Invalid uid: %r" % uid)
        userDir = os.path.join(self.server.storeDir, uid)
        if not os.path.isdir(userDir):
            os.mkdir(userDir)
        promptFile = os.path.join(userDir, promptId + '.wav')
        length = int(self.headers['Content-Length'])

        with open(promptFile, 'w') as f:
            f.write(self.rfile.read(length))

        print uid + ", " + promptId

        filename=promptId+".wav"
        
        return {"uid":uid, "fileId":filename}


class HttpServer(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
    def __init__(self, hostAndPort, dbFile, storeDir):
        BaseHTTPServer.HTTPServer.__init__(self, hostAndPort, TorfRequestHandler)
        self.dbFile = dbFile
        self.storeDir = storeDir
