#!python
#encoding: utf-8
import os, re, traceback, BaseHTTPServer, SocketServer, json, sys, cgi, uuid, sqlite3

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

    def getPostResponse(self, path, query):
        if path == '/resetDatabase':
            raise ValueError("Refused to reset database")
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
                {"identifier": "sample1", "text": u"AGOR, AGOR, CAU, CAU, AGOR, AGOR, CAU, CAU"},
                {"identifier": "sample2", "text": u"I'R CHWITH, I'R DDE, I'R DDE, I'R CHWITH, I'R CHWITH, I'R DDE"}, 
                {"identifier": "sample3", "text": u"I FYNY, I FYNY, I LAWR, I LAWR, I FYNY, I FYNY, I LAWR, I LAWR"},
                {"identifier": "sample4", "text": u"LAN, LAN, I LAWR, I LAWR, LAN, LAN, I LAWR, I LAWR"},
                {"identifier": "sample5", "text": u"YMLAEN, YMLAEN, YMLAEN, YMLAEN"},
                {"identifier": "sample6", "text": u"GAFAEL, GAFAEL, ARDDWRN, ARDDWRN, GAFAEL, GAFAEL, ARDDWRN, ARDDWRN"},
                {"identifier": "sample7", "text": u"YSGWYDD, YSGWYDD, PENELIN, PENELIN, YSGWYDD, YSGWYDD, PENELIN, PENELIN"},
                {"identifier": "sample8", "text": u"GOLAU, GOLAU, TROI, TROI, GOLAU, GOLAU, TROI, TROI"},
                {"identifier": "sample9", "text": u"GAFAEL AGOR, GAFAEL CAU, GAFAEL AGOR, GAFAEL CAU"},
                {"identifier": "sample10", "text": u"PENELIN I FYNY, PENELIN I LAWR, YSGWYDD I FYNY, YSGWYDD I LAWR"},
                {"identifier": "sample11", "text": u"PENELIN LAN, PENELIN I LAWR, YSGWYDD LAN, YSGWYDD I LAWR"},
                {"identifier": "sample12", "text": u"ARDDWRN I FYNY, ARDDWRN I LAWR, ARDDWRN I FYNY, ARDDWRN I LAWR"},
                {"identifier": "sample13", "text": u"ARDDWRN LAN, ARDDWRN I LAWR, ARDDWRN LAN, ARDDWRN I LAWR"},
                {"identifier": "sample14", "text": u"TROI I'R CHWITH, TROI I'R DDE, TROI I'R CHWITH, TROI I'R DDE"},
                {"identifier": "sample15", "text": u"AFAL, MAM, GORAU, GEMAU"},  
                {"identifier": "sample16", "text": u"MÂN, GADAEL, BLAEN, HADAU"},
                {"identifier": "sample17", "text": u"DAU, AWR, DYSGWYR, DIGWYDD"},       
                {"identifier": "sample18", "text": u"CLOI, PENODOL , SEREN, I GYD"},     
                {"identifier": "sample19", "text": u"MELIN, GORAU, BANGOR, ASGWRN"},     
                {"identifier": "sample20", "text": u"HYNNY, CATH, DEG, ADDAS"},  
                {"identifier": "sample21", "text": u"DDOE, GADAEL, AGOS, LARWM"},
                {"identifier": "sample22", "text": u"ALAW, AFAL, YMLACIO, ANODD"},   
                {"identifier": "sample23", "text": u"BRAN, PEDWERYDD, AWR, BANGOR"}, 
                {"identifier": "sample24", "text": u"BARN, TRO, YMLACIO, FYCHAN"},
                {"identifier": "sample25", "text": u"AFAL, MYNYDD, TRO"},
                {"identifier": "sample26", "text": u"YSGOL, ASGWRN, CHWAER, CATH"},
                {"identifier": "sample27", "text": u"CHWECH, AFAL, MAM, GORAU"},
                {"identifier": "sample28", "text": u"GEMAU, MÂN, GADAEL, BLAEN"},
		        {"identifier": "sample29", "text": u"HADAU, DAU, AWR, DYSGWYR"},
                {"identifier": "sample30", "text": u"DIGWYDD, CLOI, PENODOL, SEREN"}, 
                {"identifier": "sample31", "text": u"I GYD, MELIN, GORAU, BANGOR"},
                {"identifier": "sample32", "text": u"ASGWRN, HYNNY, CATH, DEG"},
                {"identifier": "sample33", "text": u"ADDAS, DDOE, GADAEL, AGOS"},
                {"identifier": "sample34", "text": u"LARWM, ALAW, AFAL, YMLACIO"}, 
                {"identifier": "sample35", "text": u"ANODD, BRAN, PEDWERYDD, AWR"}, 
                {"identifier": "sample36", "text": u"BANGOR, BARN, TRO, YMLACIO"},
                {"identifier": "sample37", "text": u"FYCHAN, MYNYDD, TRO, YSGOL"},
                {"identifier": "sample38", "text": u"ASGWRN, CHWAER, CATH, AFAL"},
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

        print uid + ", " + promptId

        filename=promptId+".wav" 
        return {"fileId":filename}

class HttpServer(SocketServer.ThreadingMixIn, BaseHTTPServer.HTTPServer):
    def __init__(self, hostAndPort, dbFile, storeDir):
        BaseHTTPServer.HTTPServer.__init__(self, hostAndPort, TorfRequestHandler)
        self.dbFile = dbFile
        self.storeDir = storeDir
