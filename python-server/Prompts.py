#!/usr/bin/env python
# -*- coding: utf-8 -*-
PROMPTS = [
    {"identifier": "sample1", "text": u"lleuad, melyn, aelodau, siarad, ffordd, ymlaen, cefnogaeth, Helen"},
    {"identifier": "sample2", "text": u"gwraig, oren, diwrnod, gwaith, mewn, eisteddfod, disgownt, iddo"},
    {"identifier": "sample3", "text": u"oherwydd, Elliw, awdurdod, blynyddoedd, gwlad, tywysog, llyw, uwch"},
    {"identifier": "sample4", "text": u"rhybuddio, Elen, uwchraddio, hwnnw, beic, Cymru, rhoi, aelod"},
    {"identifier": "sample5", "text": u"rhai, steroid, cefnogaeth, felen, cau, garej, angau, ymhlith"},
    {"identifier": "sample6", "text": u"gwneud, iawn, un, dweud, llais, wedi, gyda, llyn"},
    {"identifier": "sample7", "text": u"lliw, yng Nghymru, gwneud, rownd, ychydig, wy, yn, llaes"},
    {"identifier": "sample8", "text": u"hyn, newyddion, ar, roedd, pan, llun, melin, sychu"},
    {"identifier": "sample9", "text": u"ychydig, glin, wrth, Huw, at, nhw, bod, bydd"},
    {"identifier": "sample10", "text": u"yn un, er mwyn, neu ddysgu, hyd yn oed, tan, ond fe aeth, ati"},
    {"identifier": "sample11", "text": u"y gymdeithas, yno yn fuan, mawr, ganrif, amser, dechrau, cyfarfod"},
    {"identifier": "sample12", "text": u"prif, rhaid bod, rheini, Sadwrn, sy'n cofio, cyntaf, rhaid cael"},
    {"identifier": "sample13", "text": u"dros y ffordd, gwasanaeth, byddai'r rhestr, hyd, llygaid, Lloegr"},
    {"identifier": "sample14", "text": u"cefn, teulu, enwedig, ond mae, y tu, y pryd, di-hid, peth, hefyd"},
    {"identifier": "sample15", "text": u"morgan, eto, yma, ddefnyddio, bach, yn wir, diwedd, llenyddiaeth"},
    {"identifier": "sample16", "text": u"ym Mryste, natur, ochr, mae hi, newid, dy gymorth, nes, gwahanol"},
    {"identifier": "sample17", "text": u"i ddod, cyngor, athrawon, bychan, neu, digwydd, hud, mynd i weld"},
    {"identifier": "sample18", "text": u"ei gilydd, cyffredin, hunain, lle, cymdeithasol, y lle, unwaith"},
    {"identifier": "sample19", "text": u"i ti, newydd, ysgrifennu, y gwaith, darllen, fyddai, addysg, daeth"},
    {"identifier": "sample20", "text": u"llywodraeth, ond, hynny, esgob, cyrraedd, a bod, gwrs, ceir"},
    {"identifier": "sample21", "text": u"rhaid gweld, chwarae, nad oedd, wedyn, flwyddyn, ond nid, ardal"},
    {"identifier": "sample22", "text": u"buasai, hanes, ddiweddar, wedi cael, o bobl, merched, ffilm, cafodd"},
    {"identifier": "sample23", "text": u"awdur, na, oedd modd, dod, yr hen, gen i, olaf, ddechrau"},
    {"identifier": "sample24", "text": u"dyna, ddigon, i beidio, bynnag, rhan, trwy, am y llyfr, y cyfnod"},
    {"identifier": "sample25", "text": u"athro, anifeiliaid, pob, o fewn, yn gwneud, cartref, elfennau"},
    {"identifier": "sample26", "text": u"er enghraifft, bron, yn fwy, ar gael, sylw, edrych arno, arall"},
    {"identifier": "sample27", "text": u"cyhoeddus, un pryd, clywed, ohonom, ei fod, aros, gwyrdd golau"},
    {"identifier": "sample28", "text": u"yn ei gwen, mai, dod o Gymru, personol, allan, wrth y ffenestr"},
    {"identifier": "sample29", "text": u"ystyr, dda, arbennig, mae'n bwysig, oeddwn, farw, nifer o wyau, maer"},
    {"identifier": "sample30", "text": u"America, ar gyfer, iaith, bellach, genedlaethol, ateb, at y bont"},
    {"identifier": "sample31", "text": u"ar y cefn, ac roedd, nesaf, i gyd, doedd dim, cynnwys, amlwg"},
    {"identifier": "sample32", "text": u"amgylchiadau, gweithwyr, fy mam, ac yn llogi, pethau, unrhyw, drws"},
    {"identifier": "sample33", "text": u"Evans, yn mynd, corff, neb, eglwys, cafwyd, sef, ar ei"},
    {"identifier": "sample34", "text": u"datblygu, ac ati, traddodiad, yn byw, ond hefyd, y dydd, Williams"},
    {"identifier": "sample35", "text": u"dosbarth, yr un, fod yn fawr, ni, yr ysgol, ail ganrif, am, nid"},
    {"identifier": "sample36", "text": u"gofynnodd, gwybod, llawer, rhywbeth, o rywle, chwilio am, oddi ar"},
    {"identifier": "sample37", "text": u"cynllun, cychwyn, diolch, llyfr, yn y blaen, dan, i ddim, cyn"},
    {"identifier": "sample38", "text": u"i'r dde, ddyletswydd, hi, mae'n hwyr, dros, megis, milltir, adeg"},
    {"identifier": "sample39", "text": u"ambell, yr ogof, yna, Lerpwl, ysgolion, parc, dal, plant"},
    {"identifier": "sample40", "text": u"mam, oedd hwn, ifanc, gellir, oesoedd canol, capel, ysgol, mlynedd"},
    {"identifier": "sample41", "text": u"o gwmpas, hon, weithiau, erbyn hyn, stori, i fod, ganddo, yn cael"},
    {"identifier": "sample42", "text": u"Sir Benfro, gweld, gilydd, ond doedd, oes, un o'ch ffrindiau, ystod"},
    {"identifier": "sample43", "text": u"ddim, ond pan, edrych, wrth gwrs, a phan, ystyried, wedi bod"},
    {"identifier": "sample44", "text": u"rhawn,	ungellog, chwitffordd, deheubarth, roberts, thaw, hawys, dduw"},
    {"identifier": "sample45", "text": u"twymyn, deio, stepdir, eingion, duc, goets, aberdaugleddau, lletchwith"},
    {"identifier": "sample46", "text": u"paill, gawsai, gyw, achub, pawb, coil, maengwyn, friwydd"},
    {"identifier": "sample47", "text": u"hei, osgoi, blaenhonddan, gaeafgwsg, doe, dreier, llangurig, pitsa"},
    {"identifier": "sample48", "text": u"uwchben, iachawdwriaeth, lluwchwynt, nghyn, jobs, clywch, arfbais, tewdwr"},
    {"identifier": "sample49", "text": u"wyau, llanddowror, dull, boen, llwynhendy, mhowys, trefdraeth, cadmiwm"},
    {"identifier": "sample50", "text": u"beuno, trotscïaeth, peipen, cerrig llwydion, ffawt, tangnefedd, fwyell, hoe"},
    {"identifier": "sample51", "text": u"bwytäwr, gweu, nghawl, rhoshirwaun, hywyn, anhunedd, pwllheli, anghofus"},
    {"identifier": "sample52", "text": u"cwmllan, uthr, rhywbeth, paent, gulddail, mewn, angheuol, rhai"},
    {"identifier": "sample53", "text": u"bwffe, iddew, daufiniog, goruwchnaturiol, dywyll, enghreifftiol, choed, hopcyn"},
    {"identifier": "sample54", "text": u"gwibdaith, pibgod, uwd, garej, llywydd, hoyw, trowsus, hyll"},
    {"identifier": "sample55", "text": u"twngsten, aifft, athletau, ffowc, ddwyieithog, carnhedryn, lloi, bawb"},
    {"identifier": "sample56", "text": u"nantclwyd, achau, culhwch, ewthanasia, maip, wddf, ciwb, gwaywffon"},
    {"identifier": "sample57", "text": u"wych, jamaica, cau, pupur, croeshoelio, menyw, gwrywdod, buwch"},
    {"identifier": "sample58", "text": u"frithgraig, cernywiaid, geuffordd, pontsenni, castellnewydd, lowri, myw, frowngoch"},
    {"identifier": "sample59", "text": u"prosser, llaeth, llaw, cegddu, stow, troell, teitl, moi"},
    {"identifier": "sample60", "text": u"wthio, beiau, wrthblaid, how, noethni, dewch, project, aur"},
    {"identifier": "sample61", "text": u"blodeuyn, mharis, bownsio, ddaeth, cnicht, alpau, thywyn, chyff"},
    {"identifier": "sample62", "text": u"hufen, cellbilen, ŵydd, fowler, phwysau, nantperis, bodffordd, cywydd"},
    {"identifier": "sample63", "text": u"lecwydd, rwsiaidd, uchafswm, ffiwsia, mhen, mêts, lleill, lleoedd"},
    {"identifier": "sample64", "text": u"lleucu, felinheli, gwrhyd, llywn, nawddsant, rheibiwr, pwllmeurig, hewl"},
    {"identifier": "sample65", "text": u"dauwynebog, cellraniad, ruffydd, llanuwchllyn, dwyffurf, cefngrwm, rhoi, efengyl"},
    {"identifier": "sample66", "text": u"ddeufaen, nhw, ffotograffau, mhortiwgal, rhithdyb, acsiwn, iawn, lloer"},
    {"identifier": "sample67", "text": u"porthcawl, twpsyn, nantlle, tabloid, nhywyn, amhleidiol, ddoi, ddrewllyd"},
    {"identifier": "sample68", "text": u"jyngl, töwr, coedpoeth, penrhiwllan, briwfwyd, doi, ieuaf, banjo"},
    {"identifier": "sample69", "text": u"fodca, trefhedyn, bywgraffiad, cofiwch, baedd, benthyg, atsain, griffiths"},
    {"identifier": "sample70", "text": u"mhic, llongau, chwaraewr, fuwch, thai, pontsticill, feurig, drewgi"},
    {"identifier": "sample71", "text": u"teithiwr, baich, fewn, huws, pnawn, rhythm, fawr, grongaer"},
    {"identifier": "sample72", "text": u"allgo, clawddnewydd, cyw, chaeau, suo, saets, cowbois, gochddu"},
    {"identifier": "sample73", "text": u"canhwyllau, bolsiefic, nghlwyd, llwyngwair, teim, taeog, alldafliad, muhammad"},
    {"identifier": "sample74", "text": u"atalnwyd, effaith, eich, glywsoch, hwyrhau, calsiwm, deugain, sioeferch"},
    {"identifier": "sample75", "text": u"caerdroea, fyw, nghwm, cwmcerwyn, rhwng, cawg, gwawr, pwyth"},
    {"identifier": "sample76", "text": u"duwynt, moreau, rhywfaint, ddwfn, rhyw, powdwr, sioeau, loegr"},
    {"identifier": "sample77", "text": u"theuluoedd, toes, porthaethwy, cibwts, rhaeadr, lliw, minoaidd, nymff"},
    {"identifier": "sample78", "text": u"magdalen, cewri, ffeuen, clwyfau, puw, sipsiwn, llai, fronhaul"},
    {"identifier": "sample79", "text": u"soia, deuawd, prawf, rois, teulu, byw, ddaw, amheus"},
    {"identifier": "sample80", "text": u"bwdhaeth, botswana, gewyn, heddiw, ebbw, storïwr, llangeitho, lleisiau"},
    {"identifier": "sample81", "text": u"caerhun, llew, arllwysiad, ieithoedd, ehangdir, ceulan, bontddu, nhrwyn"},
    {"identifier": "sample82", "text": u"ddoe, secco, hirhoedlog, tywyll, fywyd, carnguwch, barhaus, haul"},
    {"identifier": "sample83", "text": u"caio, piws, corhelgi, maesllyn, foicotio, giw, jin, dawch"},
    {"identifier": "sample84", "text": u"pwllcrochan, camfa, rhew, croesryw, caib, ffacbys, clustdlws, hiwmor"},
    {"identifier": "sample85", "text": u"gowt, jiwdo, niwclews, corsiog, meudwyol, einioes, bwâu"},
]
