#!python
#encoding: utf-8
import os, re, traceback, BaseHTTPServer, SocketServer, json, sys, cgi, uuid, sqlite3

def getParam(query, name, decodeUtf8=True):
    val = query.get(name)[0]
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
            return self.getOutstandingPrompts(uid)
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
                "explanation": u"Atebwch 'Iaith Gyntaf' os oes gennych chi acen iaith gyntaf, neu 'Dysgwr' os oes gennych chi acen dysgwr.",
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
                {"identifier": "sample1", "text": u"lleuad, melyn, aelodau, siarad, ffordd, ymlaen, cefnogaeth, Helen"},
                {"identifier": "sample2", "text": u"gwraig, oren, diwrnod, gwaith, mewn, eisteddfod, disgownt, iddo"},
                {"identifier": "sample3", "text": u"oherwydd, Elliw, awdurdod, blynyddoedd, gwlad, tywysog, llyw, uwch"},
                {"identifier": "sample4", "text": u"rhybuddio, Elen, uwchraddio, hwnnw, beic, Cymru, rhoi, aelod"},
                {"identifier": "sample5", "text": u"rhai, steroid, cefnogaeth, felen, cau, garej, angau, ymhlith"},
                {"identifier": "sample6", "text": u"gwneud, iawn, un, dweud, llais, wedi, gyda, llyn"},
                {"identifier": "sample7", "text": u"lliw, yng Nghymru, gwneud, rownd, ychydig, wy, yn, llaes"},
                {"identifier": "sample8", "text": u"hyn, newyddion, ar, roedd, pan, llun, melin, sychu"},
                {"identifier": "sample9", "text": u"ychydig, glin, wrth, Huw, at, nhw, bod, bydd"},
        ]

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
