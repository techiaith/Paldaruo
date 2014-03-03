import os, re, traceback, BaseHTTPServer, SocketServer, json, sys, cgi, uuid, sqlite3

class AuthError(Exception):
    pass

class TorfRequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != '/':
            self.send_response(404)
            self.end_headers()
            self.wfile.close()
            return
        self.send_response(200)
        self.send_header('content-type', 'text/html')
        self.end_headers()
        with open('test.html') as f:
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

    def getPostResponse(self, path, query):
        if path == '/resetDatabase':
            return self.resetDatabase()
        if path == '/createUser':
            return self.createUser()
        uid = query.get('uid')[0]
        #self.checkUid(uid)
        if path == '/getMetadata':
            return self.getMetadata()
        elif path == '/saveMetadata':
            return self.saveMetadata(uid, query.get('metadata')[0])
        elif path == '/getOutstandingPrompts':
            return self.getOutstandingPrompts(uid)
        elif path == '/savePrompt':
            return self.savePrompt(uid, query.get('promptId')[0], query.get('file')[0])
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
        return [
            # Blwyddyn geni
            {
                "id": u"blwyddyngeni",
                "title": u"Blwyddyn Geni",
                "question": u"Ym mha flwyddyn cawsoch chi eich geni?",
                "explanation": u"",
                "options": None,
            },
            {
                "id": u"rhyw",
                "title": u"Rhyw",
                "question": u"Beth yw'ch rhyw?",
                "explanation": u"Rydyn ni angen gwybod pa fath o lais sydd gennych chi",
                "options": [
                    {"id": u"benyw", "text": u"Benyw"},
                    {"id": u"gwryw", "text": u"Gwryw"},
                ],
            },
            {
                "id": u"plentyndod",
                "title": u"Rhanbarth Plentyndod",
                "question": u"Ym mha ranbarth treuliasoch chi'r rhan fwyaf o'ch plentyndod?",
                "explanation": u"",
                "options": [
                    {"id": u"d_dd", "text": u"De Ddwyrain Cymru"},
                    {"id": u"d_o", "text": u"De Orllewin Cymru"},
                    {"id": u"g_dd", "text": u"Gogledd Ddwyrain Cymru"},
                    {"id": u"g_o", "text": u"Gogledd Orllewin Cymru"},
                    {"id": u"c", "text": u"Canolbarth Cymru"},
                    {"id": u"a", "text": u"Gogledd Lloegr"},
                    {"id": u"a", "text": u"Canolbarth Lloegr"},
                    {"id": u"a", "text": u"De Lloegr"},
                    {"id": u"a", "text": u"Gwlad arall"},
                    {"id": u"c", "text": u"Nifer o ardaloedd"},
                ],
            },
            {
                "id": u"ysgoluwchradd",
                "title": u"Ysgol Uwchradd",
                "question": u"Enwch eich ysgol uwchradd olaf",
                "explanation": u"Os nad ydych chi wedi mynd i'r ysgol uwchradd, rhowch 'dim'",
                "options": None,
            },
            {
                "id": u"byw",
                "title": u"Lleoliad Byw",
                "question": u"Ble rydych chi'n byw ar hyn o bryd?",
                "explanation": u"Myfyrwyr prifysgol: dewiswch eich cartref yn ystod y gwyliau",
                "options": [
                    {"id": u"d_dd", "text": u"De Ddwyrain Cymru"},
                    {"id": u"d_o", "text": u"De Orllewin Cymru"},
                    {"id": u"g_dd", "text": u"Gogledd Ddwyrain Cymru"},
                    {"id": u"g_o", "text": u"Gogledd Orllewin Cymru"},
                    {"id": u"c", "text": u"Canolbarth Cymru"},
                    {"id": u"a", "text": u"Gogledd Lloegr"},
                    {"id": u"a", "text": u"Canolbarth Lloegr"},
                    {"id": u"a", "text": u"De Lloegr"},
                    {"id": u"a", "text": u"Gwlad arall"},
                    {"id": u"c", "text": u"Nifer o ardaloedd"},
                ],
            },
            {
                "id": u"amlder",
                "title": u"Amlder Siarad Cymraeg",
                "question": u"Fel arfer, pa mor aml ydych chi'n siarad Cymraeg?",
                "explanation": u"",
                "options": [
                    {"id": u"dim", "text": u"Llai nag awr y mis"},
                    {"id": u"mis", "text": u"O leiaf awr y mis"},
                    {"id": u"wythnos", "text": u"O leiaf awr yr wythnos"},
                    {"id": u"dydd", "text": u"O leiaf awr y dydd"},
                    {"id": u"hanner", "text": u"Tua hanner yr amser"},
                    {"id": u"rhanfwyaf", "text": u"Rhan fwyaf o'r amser"},
                    {"id": u"trwyramser", "text": u"Bron yn ddieithriad"},
                ],
            },
            {
                "id": u"cyd_destun",
                "title": u"Siarad Cymraeg",
                "question": u"Ym mha gyd-destun rydych chi'n siarad Cymraeg yn rheolaidd?",
                "explanation": u"Dewiswch y cyd-destunau ble rydych chi'n siarad Cymraeg unwaith yr wythnos neu fwy",
                "options": [
                    {"id": u"dim", "text": u"Ddim yn siarad Cymraeg yn rheolaidd"},
                    {"id": u"g", "text": u"Gartref yn unig"},
                    {"id": u"y", "text": u"Ysgol/coleg/gwaith yn unig"},
                    {"id": u"ff", "text": u"Gyda ffrindiau yn unig"},
                    {"id": u"g_y", "text": u"Gartref + Ysgol/coleg/gwaith"},
                    {"id": u"g_ff", "text": u"Gartref + Ffrindiau"},
                    {"id": u"y_ff", "text": u"Ysgol/coleg/gwaith + Ffrindiau"},
                    {"id": u"g_y_ff", "text": u"Gartref + Ysgol/coleg/gwaith + Ffrindiau"},
                    {"id": u"a", "text": u"Arall"},
                ],
            },
            {
                "id": u"iaithgyntaf",
                "title": u"Acen Iaith Gyntaf",
                "question": u"Ydych chi'n siarad Cymraeg gydag acen iaith gyntaf?",
                "explanation": u"Atebwch 'Iaith Gyntaf' os os gennych chi acen iaith gyntaf, neu 'Dysgwr' os oes gennych chi acen dysgwr.",
                "options": [
                    {"id": u"dysgwr", "text": u"Acen Dysgwr"},
                    {"id": u"iaithgyntaf", "text": u"Acen Iaith Gyntaf"},
                ],
            },
            {
                "id": u"rhanbarth",
                "title": u"Acen Ranbarthol",
                "question": u"Acen pa ranbarth sydd gennych chi?",
                "explanation": u"Dewiswch yr ardal mae'ch acen yn dod ohoni (hyd yn oed os ydych chi'n byw yn rhywle arall)",
                "options": [
                    {"id": u"d_dd", "text": u"De Ddwyrain"},
                    {"id": u"d_o", "text": u"De Orllewin"},
                    {"id": u"g_dd", "text": u"Gogledd Ddwyrain"},
                    {"id": u"g_o", "text": u"Gogledd Orllewin"},
                    {"id": u"c", "text": u"Canolbarth"},
                    {"id": u"c", "text": u"Acen gymysg/Arall"},
                ],
            },
        ]

    def saveMetadata(self, uid, metadata):
        db = self.dbConnect()
        db.execute("update users set metadata=? where uid=?", (metadata, uid))
        return {}

    def getOutstandingPrompts(self, uid):
        return [
                {"identifier": "sample1", "text": "AGOR AGOR CAU CAU AGOR AGOR CAU CAU"},
                {"identifier": "sample2", "text": "CHWITH CHWITH DE DE CHWITH CHWITH DE DE"}, 
                {"identifier": "sample3", "text": "I FYNY, I FYNY, I LAWR, I LAWR, I FYNY, I FYNY, I LAWR, I LAWR"},
                {"identifier": "sample4", "text": "LAN, LAN, I LAWR, I LAWR, LAN, LAN, I LAWR, I LAWR"},
                {"identifier": "sample5", "text": "GAFAEL GAFAEL ARDDWRN ARDDWRN GAFAEL GAFAEL ARDDWRN ARDDWRN"},
                {"identifier": "sample6", "text": "YSGWYDD YSGWYDD PENELIN PENELIN YSGWYDD YSGWYDD PENELIN PENELIN"},
                {"identifier": "sample7", "text": "GOLAU, YMLAEN, GOLAU, I FFWRDD, GOLAU, YMLAEN, GOLAU, I FFWRDD"},
                {"identifier": "sample8", "text": "GOLAU YMLAEN GOLAU BANT GOLAU YMLAEN GOLAU BANT"}, 
                {"identifier": "sample9", "text": "GAFAEL AGOR GAFAEL CAU GAFAEL AGOR GAFAEL CAU"},
                {"identifier": "sample10", "text": "PENELIN, I FYNY, PENELIN, I LAWR, YSGWYDD, I FYNY, YSGWYDD, I LAWR"},
                {"identifier": "sample11", "text": "PENELIN, LAN, PENELIN, I LAWR, YSGWYDD, LAN, YSGWYDD, I LAWR"},
                {"identifier": "sample12", "text": "ARDDWRN DE ARDDWRN CHWITH ARDDWRN DE ARDDWRN CHWITH"},
        ]


    def savePrompt(self, uid, promptId, fileData):
        if not re.match(r"^[0-9A-Za-z_]+$", promptId):
            raise ValueError("Invalid promptId: %r" % promptId)
        if not os.path.isdir(self.server.storeDir):
            os.mkdir(self.server.storeDir)
        userDir = os.path.join(self.server.storeDir, uid)
        if not os.path.isdir(userDir):
            os.mkdir(userDir)
        promptFile = os.path.join(userDir, promptId + '.wav')
        with open(promptFile, 'w') as f:
            f.write(fileData)

class HttpServer(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
    def __init__(self, hostAndPort, dbFile, storeDir):
        BaseHTTPServer.HTTPServer.__init__(self, hostAndPort, TorfRequestHandler)
        self.dbFile = dbFile
        self.storeDir = storeDir
