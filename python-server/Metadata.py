#/usr/bin/env python
#encoding: UTF-8
QUESTIONS = [
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
