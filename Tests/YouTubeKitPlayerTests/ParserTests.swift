//
//  ParserTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 14.08.2024.
//

import XCTest
@testable import YouTubeKit

@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
final class ParserTests: XCTestCase {
    
    func testJavascriptFunctionExtraction() throws {
        
        let html = #"""
        xyz {var b=a.split(a.slice(0,0)),c=[1505996300,"{(}{{,",1525288969,-1090456871,223444415,-1282986135,b,-945169015,-1896234169,74589704,1613328708,function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 58:d-=14;case 91:case 92:case 93:continue;case 123:d=47;case 94:case 95:case 96:continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        2042209855,1416926377,-18760920,-1185487001,function(d,e){d=(d%e.length+e.length)%e.length;e.splice(-d).reverse().forEach(function(f){e.unshift(f)})},
        -2089946182,/[/"}][,]/,function(d){d.reverse()},
        null,function(d,e){e=(e%d.length+d.length)%d.length;d.splice(e,1)},
        -691839576,"2zvg",function(d,e){e.length!=0&&(d=(d%e.length+e.length)%e.length,e.splice(0,1,e.splice(d,1,e[0])[0]))},
        -1700369869,-1261244640,-88551131,-1821420587,-1617787839,-381728833,-1591452339,1309101862,-451144149,1550999698,-292577729,422539442,652999601,-1631488623,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 58:d=96;continue;case 91:d=44;break;case 65:d=47;continue;case 46:d=153;case 123:d-=58;default:e.push(String.fromCharCode(d))}return e},
        1273330482,-73630117,function(d,e,f,h,l,m,n){return d(l,m,n)},
        -408577047,-1419240096,function(d,e,f){var h=f.length;e.forEach(function(l,m,n){this.push(n[m]=f[(f.indexOf(l)-f.indexOf(this[m])+m+h--)%f.length])},d.split(""))},
        1337469658,644439893,1462499492,868563260,-1279720833,-2134942873,null,-854452500,1984861446,function(d,e){for(d=(d%e.length+e.length)%e.length;d--;)e.unshift(e.pop())},
        -1442560429,1752890594,-597076406,function(d,e){if(d.length!=0){e=(e%d.length+d.length)%d.length;var f=d[0];d[0]=d[e];d[e]=f}},
        -1276864031,255771450,b,-925516204,799058408,-1049096726,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 46:d=95;default:e.push(String.fromCharCode(d));case 94:case 95:case 96:break;case 123:d-=76;case 92:case 93:continue;case 58:d=44;case 91:}return e},
        1731280202,function(d,e,f,h,l){return e(f,h,l)},
        -1011506071,null,519135415,-1408835970,b,function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 91:d=44;continue;case 123:d=65;break;case 65:d-=18;continue;case 58:d=96;continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        -1637661838,569607649,function(d,e,f,h,l,m,n,p){return e(f,h,l,m,n,p)},
        1227341869,function(d){for(var e=d.length;e;)d.push(d.splice(--e,1)[0])},
        ")}'';,{",function(d,e,f,h,l,m){return e(h,l,m)},
        -347449512,1535736165,-530926627,1374892355];c[20]=c;c[52]=c;c[70]=c;try{try{c[40]>=31+Math.pow(5,1)+-39&&((0,c[81])(((0,c[59])(c[73],c[82]),c[59])(c[20],c[61]),c[16],(0,c[68])((0,c[55])(c[84],c[20]),c[18],c[14],c[36]),c[35],c[15]),"8")||((((0,c[13])(c[57],c[3]),c[18])(c[17],c[82]),(0,c[42])(c[20],c[70],(0,c[36])()),c[42])(c[20],c[70],(0,c[63])()),c[34-9*Math.pow(2,1)])(c[3]),c[61]>1&&(0,c[13])(c[5],c[70]),c[11]<-3&&((((((0,c[76])(c[70]),(0,c[18])(c[65-Math.pow(8,4)- -4090],c[11]),c[74])(((0,c[65])(((0,c[13])(c[80],
        c[49]),c[79])(c[4],c[23]),c[79],c[4],c[101%Math.pow(5,3)-100]),c[44])(c[42],c[82]),c[2],(0,c[36])(c[-20687-Math.pow(5,2)+20767],c[72])|(0,c[77])(c[20],c[59]),c[69],c[66],c[37]),c[18])(c[78],(0,c[44])((((((0,c[31])(c[33],c[82]),c[Math.pow(7,4)+112-2502])(c[57],c[62]),c[52])(c[13],c[69]),c[9])(c[2],c[13]),c[73])((0,c[29])(c[70],c[11]),c[64],c[75],c[51]),c[21],c[39],c[78]),(0,c[26])(c[67],c[63]),(0,c[26])(c[78],c[45]),c[69],c[57]),c[7])(c[79],c[64]),c[50])(c[83],c[19]),"2")||((((((0,c[36])(c[29580+Math.pow(7,
        4)-31967],c[64],(0,c[72])()),c[46])(c[81],c[83]),c[Math.pow(6,3)- -29064-29273])(c[21],c[53]),c[68])(((0,c[36])(c[14],c[83],(0,c[72])()),c[36])(c[14],c[83],(0,c[72])()),c[59],(0,c[70])(c[64]),c[36],c[14],c[83],(0,c[30])()),c[59])(((((0,c[new Date("1969-12-31T16:15:59.000-07:45")/1E3])(((0,c[Math.pow(3,1)*52-144])(c[64],c[3]),c[15])(c[28],c[11]),c[12],c[53],c[38]),c[15])(c[47],c[53]),c[12])(c[Math.pow(7,1)- -12084-12038],c[32]),((0,c[70])(c[83]),c[70])(c[83]),c[44571+Math.pow(3,2)+-44544])(c[14],c[83],
        (0,c[65])()),c[12],c[83],c[22]),c[52])((0,c[7])(c[1],c[Math.pow(2,3)-120- -165]),c[46],(0,c[52])((0,c[36])(c[14],c[53],(0,c[65])()),c[7],(0,c[36])(c[14],c[64],(0,c[30])()),c[8],c[43]),c[45],c[53]),c[41]<6&&(c[44]>=9||((0,c[50])(c[61],c[34]),(0,c[15])(c[40],c[53]),(0,c[59])((0,c[15])(c[23],c[64]),c[10],c[53]),0))&&(0,c[995387-128*Math.pow(6,5)])((0,c[36])(c[14],c[64],(0,c[72])()),c[36],c[14],c[53],(0,c[30])())%((0,c[36])(c[14],c[53],(0,c[2])()),(0,c[36])(c[14],c[64],(0,c[30])())),c[40]<=5?(0,c[36])(c[14],
        c[53],(0,c[65])()):(0,c[15])(c[29],c[11]),c[84]<=7&&(c[55]!==9&&((0,c[15])(c[128*Math.pow(new Date("1970-01-01T02:30:07.000+02:30")/1E3,4)-307311],c[11]),"3")||(0,c[12])(c[61],c[82])),c[24]<new Date("1969-12-31T20:45:04.000-03:15")/1E3&&(c[48]!==4&&((0,c[46])(c[24],c[11]),1)||(0,c[81])(c[36],c[60])),c[78]>=1&&(c[73]<=-10?(0,c[19])(c[83],c[47],(0,c[13])()):(0,c[84])(c[24],c[66])),c[6]!==-2&&((((0,c[29])(c[45],c[26]),((0,c[17])(c[76],c[74]),c[22])(c[7],c[new Date("1969-12-31T19:45:30.000-04:15")/1E3]),
        c[Math.pow(4,2)*-132- -2158])(c[24],c[63],(0,c[82])()),c[60])(c[21],c[73]),"undefined")||(((0,c[62])((0,c[22])(c[21],c[28]),c[22],(0,c[46])(c[24],c[74],(0,c[12])()),c[63],c[67]),c[46])(c[24],c[74],(0,c[12])()),c[-75*Math.pow(7,1)+585])(c[21],c[64])}catch(d){(0,c[62])((0,c[46])(c[24],c[74],(0,c[75])()),c[46],(0,c[22])(c[21],c[49]),c[24],c[386-312%Math.pow(5,5)],(0,c[12])()),(((0,c[155-Math.pow(4,3)+-69])(c[0],c[70]),c[46])(c[24],c[7],(0,c[82])()),c[22])(c[63],c[26])>>(0,c[22])(c[7],c[45]),(0,c[new Date("1970-01-01T04:00:46.000+04:00")/
        1E3])(c[24],c[74],(0,c[75])()),(0,c[22])(c[63],c[37])}}catch(d){return"enhanced_except_55sBmOT-_w8_"+a}return b.join("")};
        g.sq=function(a){this.name=a};
        Oma=function(a){this.xb=Tf(a)};
        tq=function(a){this.xb=Tf(a)};
        """#
        
        let expectedJS = #"""
        {var b=a.split(a.slice(0,0)),c=[1505996300,"{(}{{,",1525288969,-1090456871,223444415,-1282986135,b,-945169015,-1896234169,74589704,1613328708,function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 58:d-=14;case 91:case 92:case 93:continue;case 123:d=47;case 94:case 95:case 96:continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        2042209855,1416926377,-18760920,-1185487001,function(d,e){d=(d%e.length+e.length)%e.length;e.splice(-d).reverse().forEach(function(f){e.unshift(f)})},
        -2089946182,/[/"}][,]/,function(d){d.reverse()},
        null,function(d,e){e=(e%d.length+d.length)%d.length;d.splice(e,1)},
        -691839576,"2zvg",function(d,e){e.length!=0&&(d=(d%e.length+e.length)%e.length,e.splice(0,1,e.splice(d,1,e[0])[0]))},
        -1700369869,-1261244640,-88551131,-1821420587,-1617787839,-381728833,-1591452339,1309101862,-451144149,1550999698,-292577729,422539442,652999601,-1631488623,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 58:d=96;continue;case 91:d=44;break;case 65:d=47;continue;case 46:d=153;case 123:d-=58;default:e.push(String.fromCharCode(d))}return e},
        1273330482,-73630117,function(d,e,f,h,l,m,n){return d(l,m,n)},
        -408577047,-1419240096,function(d,e,f){var h=f.length;e.forEach(function(l,m,n){this.push(n[m]=f[(f.indexOf(l)-f.indexOf(this[m])+m+h--)%f.length])},d.split(""))},
        1337469658,644439893,1462499492,868563260,-1279720833,-2134942873,null,-854452500,1984861446,function(d,e){for(d=(d%e.length+e.length)%e.length;d--;)e.unshift(e.pop())},
        -1442560429,1752890594,-597076406,function(d,e){if(d.length!=0){e=(e%d.length+d.length)%d.length;var f=d[0];d[0]=d[e];d[e]=f}},
        -1276864031,255771450,b,-925516204,799058408,-1049096726,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 46:d=95;default:e.push(String.fromCharCode(d));case 94:case 95:case 96:break;case 123:d-=76;case 92:case 93:continue;case 58:d=44;case 91:}return e},
        1731280202,function(d,e,f,h,l){return e(f,h,l)},
        -1011506071,null,519135415,-1408835970,b,function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 91:d=44;continue;case 123:d=65;break;case 65:d-=18;continue;case 58:d=96;continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        -1637661838,569607649,function(d,e,f,h,l,m,n,p){return e(f,h,l,m,n,p)},
        1227341869,function(d){for(var e=d.length;e;)d.push(d.splice(--e,1)[0])},
        ")}'';,{",function(d,e,f,h,l,m){return e(h,l,m)},
        -347449512,1535736165,-530926627,1374892355];c[20]=c;c[52]=c;c[70]=c;try{try{c[40]>=31+Math.pow(5,1)+-39&&((0,c[81])(((0,c[59])(c[73],c[82]),c[59])(c[20],c[61]),c[16],(0,c[68])((0,c[55])(c[84],c[20]),c[18],c[14],c[36]),c[35],c[15]),"8")||((((0,c[13])(c[57],c[3]),c[18])(c[17],c[82]),(0,c[42])(c[20],c[70],(0,c[36])()),c[42])(c[20],c[70],(0,c[63])()),c[34-9*Math.pow(2,1)])(c[3]),c[61]>1&&(0,c[13])(c[5],c[70]),c[11]<-3&&((((((0,c[76])(c[70]),(0,c[18])(c[65-Math.pow(8,4)- -4090],c[11]),c[74])(((0,c[65])(((0,c[13])(c[80],
        c[49]),c[79])(c[4],c[23]),c[79],c[4],c[101%Math.pow(5,3)-100]),c[44])(c[42],c[82]),c[2],(0,c[36])(c[-20687-Math.pow(5,2)+20767],c[72])|(0,c[77])(c[20],c[59]),c[69],c[66],c[37]),c[18])(c[78],(0,c[44])((((((0,c[31])(c[33],c[82]),c[Math.pow(7,4)+112-2502])(c[57],c[62]),c[52])(c[13],c[69]),c[9])(c[2],c[13]),c[73])((0,c[29])(c[70],c[11]),c[64],c[75],c[51]),c[21],c[39],c[78]),(0,c[26])(c[67],c[63]),(0,c[26])(c[78],c[45]),c[69],c[57]),c[7])(c[79],c[64]),c[50])(c[83],c[19]),"2")||((((((0,c[36])(c[29580+Math.pow(7,
        4)-31967],c[64],(0,c[72])()),c[46])(c[81],c[83]),c[Math.pow(6,3)- -29064-29273])(c[21],c[53]),c[68])(((0,c[36])(c[14],c[83],(0,c[72])()),c[36])(c[14],c[83],(0,c[72])()),c[59],(0,c[70])(c[64]),c[36],c[14],c[83],(0,c[30])()),c[59])(((((0,c[new Date("1969-12-31T16:15:59.000-07:45")/1E3])(((0,c[Math.pow(3,1)*52-144])(c[64],c[3]),c[15])(c[28],c[11]),c[12],c[53],c[38]),c[15])(c[47],c[53]),c[12])(c[Math.pow(7,1)- -12084-12038],c[32]),((0,c[70])(c[83]),c[70])(c[83]),c[44571+Math.pow(3,2)+-44544])(c[14],c[83],
        (0,c[65])()),c[12],c[83],c[22]),c[52])((0,c[7])(c[1],c[Math.pow(2,3)-120- -165]),c[46],(0,c[52])((0,c[36])(c[14],c[53],(0,c[65])()),c[7],(0,c[36])(c[14],c[64],(0,c[30])()),c[8],c[43]),c[45],c[53]),c[41]<6&&(c[44]>=9||((0,c[50])(c[61],c[34]),(0,c[15])(c[40],c[53]),(0,c[59])((0,c[15])(c[23],c[64]),c[10],c[53]),0))&&(0,c[995387-128*Math.pow(6,5)])((0,c[36])(c[14],c[64],(0,c[72])()),c[36],c[14],c[53],(0,c[30])())%((0,c[36])(c[14],c[53],(0,c[2])()),(0,c[36])(c[14],c[64],(0,c[30])())),c[40]<=5?(0,c[36])(c[14],
        c[53],(0,c[65])()):(0,c[15])(c[29],c[11]),c[84]<=7&&(c[55]!==9&&((0,c[15])(c[128*Math.pow(new Date("1970-01-01T02:30:07.000+02:30")/1E3,4)-307311],c[11]),"3")||(0,c[12])(c[61],c[82])),c[24]<new Date("1969-12-31T20:45:04.000-03:15")/1E3&&(c[48]!==4&&((0,c[46])(c[24],c[11]),1)||(0,c[81])(c[36],c[60])),c[78]>=1&&(c[73]<=-10?(0,c[19])(c[83],c[47],(0,c[13])()):(0,c[84])(c[24],c[66])),c[6]!==-2&&((((0,c[29])(c[45],c[26]),((0,c[17])(c[76],c[74]),c[22])(c[7],c[new Date("1969-12-31T19:45:30.000-04:15")/1E3]),
        c[Math.pow(4,2)*-132- -2158])(c[24],c[63],(0,c[82])()),c[60])(c[21],c[73]),"undefined")||(((0,c[62])((0,c[22])(c[21],c[28]),c[22],(0,c[46])(c[24],c[74],(0,c[12])()),c[63],c[67]),c[46])(c[24],c[74],(0,c[12])()),c[-75*Math.pow(7,1)+585])(c[21],c[64])}catch(d){(0,c[62])((0,c[46])(c[24],c[74],(0,c[75])()),c[46],(0,c[22])(c[21],c[49]),c[24],c[386-312%Math.pow(5,5)],(0,c[12])()),(((0,c[155-Math.pow(4,3)+-69])(c[0],c[70]),c[46])(c[24],c[7],(0,c[82])()),c[22])(c[63],c[26])>>(0,c[22])(c[7],c[45]),(0,c[new Date("1970-01-01T04:00:46.000+04:00")/
        1E3])(c[24],c[74],(0,c[75])()),(0,c[22])(c[63],c[37])}}catch(d){return"enhanced_except_55sBmOT-_w8_"+a}return b.join("")}
        """#
        
        let extractedJSFunction = try Parser.findJavascriptFunctionFromStartpoint(html: html, startPoint: html.index(html.startIndex, offsetBy: 4))
        
        XCTAssertEqual(extractedJSFunction, expectedJS)
        
    }
    
    func testJavascriptFunctionExtractionOvershootIssue() throws {
        
        let html = #"""
        Zma=function(a){var b=a.split(a.slice(0,0)),c=[-887308459,-1781804826,-781207296,-1144989195,-1294330582,-1129039296,-1864493163,b,function(d,e){for(e=(e%d.length+d.length)%d.length;e--;)d.unshift(d.pop())},
        1968856957,-779898976,1730192811,-397172030,-601216764,-355481697,-1475269130,1837949897,-1781804826,function(d,e){e=(e%d.length+d.length)%d.length;d.splice(-e).reverse().forEach(function(f){d.unshift(f)})},
        -855430905,-1339403662,function(d){d.reverse()},
        -1988979994,-802647208,-1284987007,-1452121604,-68131210,-312982223,b,-1449192580,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 46:d=95;default:e.push(String.fromCharCode(d));case 94:case 95:case 96:break;case 123:d-=76;case 92:case 93:continue;case 58:d=44;case 91:}return e},
        158532445,1976926208,",51];c[56]=c;",1572188298,2092390308,function(d,e){if(e.length!=0){d=(d%e.length+e.length)%e.length;var f=e[0];e[0]=e[d];e[d]=f}},
        "else",-883305643,1596914721,function(d,e){d.push(e)},
        -2130627225,-1997514831,144094072,324706570,1103721461,-359407835,651014498,1524743960,function(d,e,f,h,l,m){return e(h,l,m)},
        function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 91:d=44;continue;case 123:d=65;break;case 65:d-=18;continue;case 58:d=96;continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        289819507,null,546752825,202819066,-1374859978,814094604,b,function(d,e,f,h,l,m,n,p,q){return f(h,l,m,n,p,q)},
        974520445,212969858,-2044332532,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 58:d=96;continue;case 91:d=44;break;case 65:d=47;continue;case 46:d=153;case 123:d-=58;default:e.push(String.fromCharCode(d))}return e},
        /'((()\\),)(),\//,81532711,function(d,e){d.length!=0&&(e=(e%d.length+d.length)%d.length,d.splice(0,1,d.splice(e,1,d[0])[0]))},
        function(d,e,f){var h=e.length;d.forEach(function(l,m,n){this.push(n[m]=e[(e.indexOf(l)-e.indexOf(this[m])+m+h--)%e.length])},f.split(""))},
        function(d,e,f,h,l){return e(f,h,l)},
        -1389791791,395991054,function(d,e,f,h,l,m,n){return d(l,m,n)},
        -485923235,function(d,e){d=(d%e.length+e.length)%e.length;e.splice(d,1)},
        395991054,null,74956677,function(d){for(var e=d.length;e;)d.push(d.splice(--e,1)[0])},
        function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 58:d-=14;case 91:case 92:case 93:continue;case 123:d=47;case 94:case 95:case 96:continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        null,1081429112,189888673];c[52]=c;c[74]=c;c[78]=c;try{try{c[16]>=3?(0,c[49])(((0,c[40])(c[78],c[31]),(0,c[8])(c[57],c[12])),c[36],((0,c[65])(c[78],c[47]),(0,c[67])((0,c[8])(c[28],c[79]),c[76],c[28]),(0,c[40])(c[52],c[5]),(0,c[18])(c[74],c[80]),c[36])(c[23],c[20]),c[37],c[38]):(0,c[44])((0,c[58])(c[70],c[38]),(((0,c[53])((0,c[7])(c[76]),c[4],c[60],c[69]),c[53])((0,c[52])(c[14],(0,c[63])(),c[23]),c[58],c[15],c[60]),c[53])((0,c[52])(c[43],(0,c[48])(),c[23]),c[58],c[20],c[76]),c[53],(0,c[52])(c[14],
        (0,c[48])(),c[23]),c[22],c[55],c[43]),c[11]===-5?((0,c[53])((0,c[52])(c[76],(0,c[48])(),c[23]),c[22],c[6],c[43]),c[77])(c[14],c[47]):((0,c[51])(c[43],c[8]),(0,c[77])(c[64],c[71]),c[new Date("1970-01-01T11:16:19.000+11:15")/1E3])(c[30],c[new Date("1970-01-01T04:46:04.000+04:45")/1E3]),c[39]!==1&&(c[4]>=4&&(((0,c[5])(c[80],c[73]),c[5])(c[72],c[23]),"null")||(0,c[0])((0,c[52])(c[41],c[73]),c[24],c[new Date("1970-01-01T09:30:11.000+09:30")/1E3],c[61])),c[7]!=2&&(c[8]>=9?((((0,c[75])(c[1],c[new Date("1970-01-01T07:00:34.000+07:00")/
        1E3]),c[18])(c[1],c[8]),c[66])(c[76],c[20]),(0,c[14])((0,c[56])(c[43],c[71]),c[6],(0,c[42])(c[15],c[63]),c[64],c[71]),c[75])(c[26],c[61])>=((0,c[35])(c[79],c[70]),c[61])(c[47]):((((0,c[27])(c[23],(0,c[22])(c[35],c[81]),(0,c[48])(c[9],c[49]),(0,c[23])(c[68],(0,c[34])(),c[77]),c[68],(0,c[19])(),c[77]),c[29])(c[75],c[68]),(0,c[23])(c[47],(0,c[70])(),c[77]),c[33])(c[14]),c[24])((0,c[61])(c[35]),c[29],c[30],c[9])),c[56]<2?(0,c[24])((0,c[33])(c[47]),c[48],c[35],c[25]):(0,c[73])((0,c[78])(c[25],c[34]),c[78],
        c[17],c[63]),c[37]>-8&&(c[35]===0?(0,c[55])((0,c[73])((0,c[27])(c[13]),c[78],c[59],c[1]),c[72],(0,c[14])(c[58],c[77]),c[13],(0,c[36])(),c[43]):((0,c[42])(c[54],c[58]),(0,c[42])(c[19],c[34]),(0,c[24])(c[58],c[44])>(0,c[77])(c[32],c[82]))),(0,c[72])((0,c[70])(c[43],c[57]),c[77],c[65],c[82]),(0,c[77])(c[49],c[62])}catch(d){c[46]<9&&(c[48]!==new Date("1970-01-01T11:45:05.000+11:45")/1E3&&((((0,c[41])(c[11],c[0]),c[81])(c[33]),c[13])(c[new Date("1969-12-31T13:16:19.000-10:45")/1E3],c[15]),1)||(((0,c[53])(c[16],
        c[34]),c[54])(c[16],(0,c[78])(),c[25]),c[54])(c[15-new Date("1970-01-01T06:14:10.000+06:15")/1E3],(0,c[38])(),c[25])),c[76]!=-2&&(0,c[55])((0,c[54])(c[new Date("1969-12-31T14:45:16.000-09:15")/1E3],(0,c[38])(),c[25]),c[24],c[4],c[65]),c[36]==-5?(0,c[55])(((0,c[60])(c[76],c[40]),c[79])(c[66],c[14]),c[54],c[65],(0,c[50])(),c[25]):(0,c[37])((0,c[6])(c[16],c[30]),c[9],(0,c[new Date("1970-01-01T03:01:19.000+03:00")/1E3])(c[16],c[3]),c[45]),c[27]!==9&&(0,c[55])((0,c[79])(c[65],c[42]),c[79],c[16],c[20])}}catch(d){return"enhanced_except_rJwB0-P-_w8_"+
        a}return b.join("")};
        g.gr=function(a){this.name=a};
        $ma=function(a){this.ub=Gd(a)};
        hr=function(a){this.ub=Gd(a)};
        ir=function(a){this.ub=Gd(a)};
        """#
        
        let expectedJS = #"""
        {var b=a.split(a.slice(0,0)),c=[-887308459,-1781804826,-781207296,-1144989195,-1294330582,-1129039296,-1864493163,b,function(d,e){for(e=(e%d.length+d.length)%d.length;e--;)d.unshift(d.pop())},
        1968856957,-779898976,1730192811,-397172030,-601216764,-355481697,-1475269130,1837949897,-1781804826,function(d,e){e=(e%d.length+d.length)%d.length;d.splice(-e).reverse().forEach(function(f){d.unshift(f)})},
        -855430905,-1339403662,function(d){d.reverse()},
        -1988979994,-802647208,-1284987007,-1452121604,-68131210,-312982223,b,-1449192580,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 46:d=95;default:e.push(String.fromCharCode(d));case 94:case 95:case 96:break;case 123:d-=76;case 92:case 93:continue;case 58:d=44;case 91:}return e},
        158532445,1976926208,",51];c[56]=c;",1572188298,2092390308,function(d,e){if(e.length!=0){d=(d%e.length+e.length)%e.length;var f=e[0];e[0]=e[d];e[d]=f}},
        "else",-883305643,1596914721,function(d,e){d.push(e)},
        -2130627225,-1997514831,144094072,324706570,1103721461,-359407835,651014498,1524743960,function(d,e,f,h,l,m){return e(h,l,m)},
        function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 91:d=44;continue;case 123:d=65;break;case 65:d-=18;continue;case 58:d=96;continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        289819507,null,546752825,202819066,-1374859978,814094604,b,function(d,e,f,h,l,m,n,p,q){return f(h,l,m,n,p,q)},
        974520445,212969858,-2044332532,function(){for(var d=64,e=[];++d-e.length-32;)switch(d){case 58:d=96;continue;case 91:d=44;break;case 65:d=47;continue;case 46:d=153;case 123:d-=58;default:e.push(String.fromCharCode(d))}return e},
        /'((()\\),)(),\//,81532711,function(d,e){d.length!=0&&(e=(e%d.length+d.length)%d.length,d.splice(0,1,d.splice(e,1,d[0])[0]))},
        function(d,e,f){var h=e.length;d.forEach(function(l,m,n){this.push(n[m]=e[(e.indexOf(l)-e.indexOf(this[m])+m+h--)%e.length])},f.split(""))},
        function(d,e,f,h,l){return e(f,h,l)},
        -1389791791,395991054,function(d,e,f,h,l,m,n){return d(l,m,n)},
        -485923235,function(d,e){d=(d%e.length+e.length)%e.length;e.splice(d,1)},
        395991054,null,74956677,function(d){for(var e=d.length;e;)d.push(d.splice(--e,1)[0])},
        function(){for(var d=64,e=[];++d-e.length-32;){switch(d){case 58:d-=14;case 91:case 92:case 93:continue;case 123:d=47;case 94:case 95:case 96:continue;case 46:d=95}e.push(String.fromCharCode(d))}return e},
        null,1081429112,189888673];c[52]=c;c[74]=c;c[78]=c;try{try{c[16]>=3?(0,c[49])(((0,c[40])(c[78],c[31]),(0,c[8])(c[57],c[12])),c[36],((0,c[65])(c[78],c[47]),(0,c[67])((0,c[8])(c[28],c[79]),c[76],c[28]),(0,c[40])(c[52],c[5]),(0,c[18])(c[74],c[80]),c[36])(c[23],c[20]),c[37],c[38]):(0,c[44])((0,c[58])(c[70],c[38]),(((0,c[53])((0,c[7])(c[76]),c[4],c[60],c[69]),c[53])((0,c[52])(c[14],(0,c[63])(),c[23]),c[58],c[15],c[60]),c[53])((0,c[52])(c[43],(0,c[48])(),c[23]),c[58],c[20],c[76]),c[53],(0,c[52])(c[14],
        (0,c[48])(),c[23]),c[22],c[55],c[43]),c[11]===-5?((0,c[53])((0,c[52])(c[76],(0,c[48])(),c[23]),c[22],c[6],c[43]),c[77])(c[14],c[47]):((0,c[51])(c[43],c[8]),(0,c[77])(c[64],c[71]),c[new Date("1970-01-01T11:16:19.000+11:15")/1E3])(c[30],c[new Date("1970-01-01T04:46:04.000+04:45")/1E3]),c[39]!==1&&(c[4]>=4&&(((0,c[5])(c[80],c[73]),c[5])(c[72],c[23]),"null")||(0,c[0])((0,c[52])(c[41],c[73]),c[24],c[new Date("1970-01-01T09:30:11.000+09:30")/1E3],c[61])),c[7]!=2&&(c[8]>=9?((((0,c[75])(c[1],c[new Date("1970-01-01T07:00:34.000+07:00")/
        1E3]),c[18])(c[1],c[8]),c[66])(c[76],c[20]),(0,c[14])((0,c[56])(c[43],c[71]),c[6],(0,c[42])(c[15],c[63]),c[64],c[71]),c[75])(c[26],c[61])>=((0,c[35])(c[79],c[70]),c[61])(c[47]):((((0,c[27])(c[23],(0,c[22])(c[35],c[81]),(0,c[48])(c[9],c[49]),(0,c[23])(c[68],(0,c[34])(),c[77]),c[68],(0,c[19])(),c[77]),c[29])(c[75],c[68]),(0,c[23])(c[47],(0,c[70])(),c[77]),c[33])(c[14]),c[24])((0,c[61])(c[35]),c[29],c[30],c[9])),c[56]<2?(0,c[24])((0,c[33])(c[47]),c[48],c[35],c[25]):(0,c[73])((0,c[78])(c[25],c[34]),c[78],
        c[17],c[63]),c[37]>-8&&(c[35]===0?(0,c[55])((0,c[73])((0,c[27])(c[13]),c[78],c[59],c[1]),c[72],(0,c[14])(c[58],c[77]),c[13],(0,c[36])(),c[43]):((0,c[42])(c[54],c[58]),(0,c[42])(c[19],c[34]),(0,c[24])(c[58],c[44])>(0,c[77])(c[32],c[82]))),(0,c[72])((0,c[70])(c[43],c[57]),c[77],c[65],c[82]),(0,c[77])(c[49],c[62])}catch(d){c[46]<9&&(c[48]!==new Date("1970-01-01T11:45:05.000+11:45")/1E3&&((((0,c[41])(c[11],c[0]),c[81])(c[33]),c[13])(c[new Date("1969-12-31T13:16:19.000-10:45")/1E3],c[15]),1)||(((0,c[53])(c[16],
        c[34]),c[54])(c[16],(0,c[78])(),c[25]),c[54])(c[15-new Date("1970-01-01T06:14:10.000+06:15")/1E3],(0,c[38])(),c[25])),c[76]!=-2&&(0,c[55])((0,c[54])(c[new Date("1969-12-31T14:45:16.000-09:15")/1E3],(0,c[38])(),c[25]),c[24],c[4],c[65]),c[36]==-5?(0,c[55])(((0,c[60])(c[76],c[40]),c[79])(c[66],c[14]),c[54],c[65],(0,c[50])(),c[25]):(0,c[37])((0,c[6])(c[16],c[30]),c[9],(0,c[new Date("1970-01-01T03:01:19.000+03:00")/1E3])(c[16],c[3]),c[45]),c[27]!==9&&(0,c[55])((0,c[79])(c[65],c[42]),c[79],c[16],c[20])}}catch(d){return"enhanced_except_rJwB0-P-_w8_"+
        a}return b.join("")}
        """#
        
        let extractedJSFunction = try Parser.findJavascriptFunctionFromStartpoint(html: html, startPoint: html.index(html.startIndex, offsetBy: 15))
        
        XCTAssertEqual(extractedJSFunction, expectedJS)
        
    }
    
    func testSimplerJavascriptFunctionExtractionOvershootIssue() throws {
        
        let html = #"""
        c=[
        /'((()\\),)(),\//];
        some extra stuff
        """#
        
        let expectedJS = #"""
        [
        /'((()\\),)(),\//]
        """#
        
        let extractedJSFunction = try Parser.findJavascriptFunctionFromStartpoint(html: html, startPoint: html.index(html.startIndex, offsetBy: 2))
        
        XCTAssertEqual(extractedJSFunction, expectedJS)
        
    }
    
    func testJavascriptFunctionExtractionSecondOvershootIssue() throws {
        
        let html = #"""
        zl2=function(D){var O=D.split(D.slice(0,0)),h=[-427713130,1898166849,-1268610843,158454752,-1830992715,-1477369753,function(V,k){k=(k%V.length+V.length)%V.length;V.splice(k,1)},
        function(V,k){k.length!=0&&(V=(V%k.length+k.length)%k.length,k.splice(0,1,k.splice(V,1,k[0])[0]))},
        12618835,1031004894,function(){for(var V=64,k=[];++V-k.length-32;){switch(V){case 58:V-=14;case 91:case 92:case 93:continue;case 123:V=47;case 94:case 95:case 96:continue;case 46:V=95}k.push(String.fromCharCode(V))}return k},
        -326732465,-1764858234,function(){for(var V=64,k=[];++V-k.length-32;){switch(V){case 91:V=44;continue;case 123:V=65;break;case 65:V-=18;continue;case 58:V=96;continue;case 46:V=95}k.push(String.fromCharCode(V))}return k},
        -1531117326,788559869,1417713365,-1939999736,function(V,k,C,M,c,S,Y,J,q){return C(M,c,S,Y,J,q)},
        "[)//,,",O,1327600884,-2094972817,2030888738,function(V,k){k=(k%V.length+V.length)%V.length;V.splice(-k).reverse().forEach(function(C){V.unshift(C)})},
        133812157,2031205568,-1325399912,719172726,-1135157672,function(V){V.reverse()},
        function(V,k,C,M,c,S,Y,J){return k(C,M,c,S,Y,J)},
        O,1537557440,-1093417944,function(V,k,C,M,c,S,Y,J,q){return C(M,c,S,Y,J,q)},
        null,/'{\({\[]\)\\\(\(;/,1417713365,-1641363049,-1853774988,-1033263471,574263106,function(V){for(var k=V.length;k;)V.push(V.splice(--k,1)[0])},
        function(V,k,C,M,c,S){return k(M,c,S)},
        function(){for(var V=64,k=[];++V-k.length-32;)switch(V){case 46:V=95;default:k.push(String.fromCharCode(V));case 94:case 95:case 96:break;case 123:V-=76;case 92:case 93:continue;case 58:V=44;case 91:}return k},
        2011083848,null,-2084042919,820960604,-1061580952,-190965445,"oV-1",-1363898396,-1679223255,function(){for(var V=64,k=[];++V-k.length-32;)switch(V){case 58:V=96;continue;case 91:V=44;break;case 65:V=47;continue;case 46:V=153;case 123:V-=58;default:k.push(String.fromCharCode(V))}return k},
        1950885797,-356854457,161504232,-1754528998,function(V,k){if(V.length!=0){k=(k%V.length+V.length)%V.length;var C=V[0];V[0]=V[k];V[k]=C}},
        -582870620,1249279923,-1231993417,-1710862565,null,-380872291,"length",-1479526010,1440556590,-282702886,-631487905,1565478257,-50587191,function(V,k,C,M,c){return k(C,M,c)},
        O,1859562986,834790388,function(V,k,C){var M=k.length;C.forEach(function(c,S,Y){this.push(Y[S]=k[(k.indexOf(c)-k.indexOf(this[S])+S+M--)%k.length])},V.split(""))},
        1312889218,-1641363049,function(V,k){for(k=(k%V.length+V.length)%V.length;k--;)V.unshift(V.pop())},
        201460517];h[36]=h;h[47]=h;h[65]=h;if(typeof d0R==="undefined")return D;try{try{(h[64]==8||((((((0,h[6])(h[75],h[28]),h[7])(h[4],h[36]),h[60])(h[47],h[2]),h[81])(h[47],h[22]),h[78])(h[46],h[new Date("1969-12-31T14:46:15.000-09:15")/1E3]),""))&&(0,h[2])((0,h[15])((0,h[52])(h[74],h[11]),h[60],(0,h[49])(h[55],(0,h[67])(),h[3]),h[46],h[68]),h[45],(0,h[49])(h[23],(0,h[64])(),h[3]),h[1],h[7]),h[53]!==-1&&(h[22]<9||((0,h[78])(h[7],h[59]),0))&&(0,h[60])(h[3],h[79]),h[5]!==6&&(h[27]==new Date("1970-01-01T06:59:56.000+07:00")/
        1E3||((0,h[6])((0,h[45])(((0,h[61])(h[50],h[74]),h[49])(h[23],(0,h[26])(),h[74]),h[61],h[62],h[3]),((((0,h[78])(h[7],h[33]),h[80])(h[35],h[8]),(0,h[53])(h[59],(0,h[71])(),h[78]),h[18])(h[11]),h[17])(h[66],h[75]),h[33],(0,h[17])(h[59],h[60]),h[17],h[57],h[75]),0))&&((0,h[33])((0,h[33])((0,h[47])(h[42],h[36]),h[17],h[30],h[4]),h[18],h[75],h[68]),(0,h[64])(h[75]),((0,h[18])(h[32],h[31]),(0,h[18])(h[32],h[80]),h[18])(h[60],h[39]),(0,h[47])(h[32],h[49]),(0,h[29])(h[23],(0,h[62])(),h[32]),h[18])(h[71],
        h[34])}catch(V){(0,h[14])(h[42],h[46]),(0,h[18])(h[4],h[44]),(0,h[18])(h[32],h[81])}try{(h[69]<6||((0,h[33])((0,h[14])(h[32],h[38]),h[47],h[42],h[25]),0))&&((0,h[64])(h[60]),h[29])(h[23],(0,h[52])(),h[32])}catch(V){(0,h[29])(h[23],(0,h[11])(),h[4])}finally{h[48]!=9&&(0,h[14])(h[60],h[50]),h[62]!==1&&((0,h[39])((0,h[40])(h[18]),h[59],(0,h[6])(h[22],h[64]),h[46],h[53]),h[59])(h[74],h[48])}try{h[26]===8&&((0,h[0])((0,h[29])(h[19]),h[6],(0,h[73])((0,h[80])(h[46],h[52]),h[77],h[1],(0,h[12])(),h[19]),h[82],
        h[64]),1)||(0,h[34])((0,h[6])(h[28],h[19]),(0,h[80])(h[35],h[37]),h[66],(0,h[82])(h[38],h[28]),h[52],h[57],h[26]),(0,h[70])(h[16],(0,h[47])(),h[39]),(0,h[70])(h[77],(0,h[47])(),h[24])}catch(V){h[60]>=9&&(((((0,h[81])(h[67],h[16]),h[70])(h[44],(0,h[47])(),h[67]),h[22])(h[12]),h[76])((0,h[81])(h[12],h[48]),h[52],(0,h[2])(h[12],h[25]),h[12],h[59]),1)||(0,h[66])((0,h[76])((0,h[2])(h[12],h[51]),h[82],((0,h[35])(h[12]),(0,h[2])(h[28],h[3]),h[25])(h[51],h[32]),h[13],h[79]),h[75],h[79])}finally{(h[60]<6||
        ((0,h[7])(h[14]),void 0))&&(0,h[7])(h[30])}try{h[8]>=-6&&(0,h[59])((0,h[44])(h[18],h[8]),h[7],h[18]),h[81]<2&&((0,h[49])((0,h[56])(h[30],h[81]),h[73],(0,h[43])(h[61],h[58]),h[18],h[35]),"undefined")||(0,h[49])((0,h[44])(h[68],h[47]),h[55],(0,h[44])(h[68],h[63]),h[82],(0,h[37])(),h[30])}catch(V){((0,h[44])(h[58],h[67]),h[55])(h[82],(0,h[78])(),h[58])}}catch(V){return"4x_dwP_iOswhp0B-eL-_w8_"+D}return O.join("")};
        nBd=function(D){return D,"undefined"[6+!!D]};
        g.wB=function(D){this.name=D};
        Fnq=function(D){this.IT=Go(D)};
        sd=function(D){this.IT=Go(D)};
        Wf=function(D){this.IT=Go(D)};
        yud=function(D){this.IT=Go(D)};
        T6=function(D){this.IT=Go(D)};
        dB=function(D){this.IT=Go(D)};
        z6=function(D){this.IT=Go(D)};
        n0=function(D){this.IT=Go(D)};
        Fe=function(D){this.IT=Go(D)};
        yv=function(D){this.IT=Go(D)};
        i5=function(D){this.IT=Go(D)};
        NU=function(D){this.IT=Go(D)};
        oV=function(D){this.IT=Go(D)};
        Z_=function(D){this.IT=Go(D)};
        Xe=function(D){this.IT=Go(D)};
        Bf=function(D){this.IT=Go(D,500)};
        l5=function(D){this.IT=Go(D)};
        xj=function(D){this.IT=Go(D)};
        isq=function(D){this.IT=Go(D)};
        ruP=function(){return g.Fk("yt.ads.biscotti.lastId_")||""};
        ptw=function(D){g.nT("yt.ads.biscotti.lastId_",D)};
        DE=function(){var D=arguments,O=IV;D.length>1?O[D[0]]=D[1]:D.length===1&&Object.assign(O,D[0])};
        g.OP=function(D,O){return D in IV?IV[D]:O};
        hO=function(D){var O=IV.EXPERIMENT_FLAGS;return O?O[D]:void 0};
        NJd=function(D){VR.forEach(function(O){return O(D)})};
        g.Cc=function(D){return D&&window.yterr?function(){try{return D.apply(this,arguments)}catch(O){g.ks(O)}}:D};
        g.ks=function(D){var O=g.Fk("yt.logging.errors.log");O?O(D,"ERROR",void 0,void 0,void 0,void 0,void 0):(O=g.OP("ERRORS",[]),O.push([D,"ERROR",void 0,void 0,void 0,void 0,void 0]),DE("ERRORS",O));NJd(D)};
        MB=function(D,O,h,V,k){var C=g.Fk("yt.logging.errors.log");C?C(D,"WARNING",O,h,V,void 0,k):(C=g.OP("ERRORS",[]),C.push([D,"WARNING",O,h,V,void 0,k]),DE("ERRORS",C))};
        bw=function(D,O){O=D.split(O);for(var h={},V=0,k=O.length;V<k;V++){var C=O[V].split("=");if(C.length===1&&C[0]||C.length===2)try{var M=oB2(C[0]||""),c=oB2(C[1]||"");if(M in h){var S=h[M];Array.isArray(S)?g.Ol(S,c):h[M]=[S,c]}else h[M]=c}catch(u){var Y=u,J=C[0],q=String(bw);Y.args=[{key:J,value:C[1],query:D,method:Zs2===q?"unchanged":q}];XtB.hasOwnProperty(J)||MB(Y)}}return h};
        cN=function(D){var O=[];g.K2(D,function(h,V){var k=g.OO(V);g.Je(Array.isArray(h)?h:[h],function(C){C==""?O.push(k):O.push(k+"="+g.OO(C))})});
        return O.join("&")};
        SW=function(D){D.charAt(0)==="?"&&(D=D.substring(1));return bw(D,"&")};
        Ys=function(D){return D.split(",").map(function(O){return SW(O)})};
        g.JO=function(D){return D.indexOf("?")!==-1?(D=(D||"").split("#")[0],D=D.split("?",2),SW(D.length>1?D[1]:D[0])):{}};
        qB=function(D,O){return BJT(D,O||{},!0)};
        uw=function(D,O){return BJT(D,O||{},!1)};
        BJT=function(D,O,h){var V=D.split("#",2);D=V[0];V=V.length>1?"#"+V[1]:"";var k=D.split("?",2);D=k[0];k=SW(k[1]||"");for(var C in O)if(h||!g.vW(k,C))k[C]=O[C];return g.lF(D,k)+V};
        HN=function(D){if(!O)var O=window.location.href;var h=g.r7(1,D),V=g.pH(D);h&&V?(D=D.match(iF),O=O.match(iF),D=D[3]==O[3]&&D[1]==O[1]&&D[4]==O[4]):D=V?g.pH(O)===V&&(Number(g.r7(4,O))||null)===(Number(g.r7(4,D))||null):!0;return D};
        mM=function(D){D||(D=document.location.href);D=g.r7(1,D);return D!==null&&D==="https"};
        eW=function(D){D=lo_(D);return D===null?!1:D[0]==="com"&&D[1].match(/^youtube(?:kids|-nocookie)?$/)?!0:!1};
        x0d=function(D){D=lo_(D);return D===null?!1:D[1]==="google"?!0:D[2]==="google"?D[0]==="au"&&D[1]==="com"?!0:D[0]==="uk"&&D[1]==="co"?!0:!1:!1};
        lo_=function(D){D=g.pH(D);return D!==null?D.split(".").reverse():null};
        oB2=function(D){return D&&D.match($0R)?D:hp(D)};
        gt=function(D){var O=Lc;D=D===void 0?ruP():D;var h=Object,V=h.assign,k=PN(O);var C=O.D;try{var M=C.screenX;var c=C.screenY}catch(E){}try{var S=C.outerWidth;var Y=C.outerHeight}catch(E){}try{var J=C.innerWidth;var q=C.innerHeight}catch(E){}try{var u=C.screenLeft;var H=C.screenTop}catch(E){}try{J=C.innerWidth,q=C.innerHeight}catch(E){}try{var m=C.screen.availWidth;var R=C.screen.availTop}catch(E){}C=[u,H,M,c,m,R,S,Y,J,q];M=PFk(!1,O.D.top);c={};var f=f===void 0?g.zR:f;S=new $7;"SVGElement"in f&&"createElementNS"in
        f.document&&S.set(0);Y=Qrk();Y["allow-top-navigation-by-user-activation"]&&S.set(1);Y["allow-popups-to-escape-sandbox"]&&S.set(2);f.crypto&&f.crypto.subtle&&S.set(3);"TextDecoder"in f&&"TextEncoder"in f&&S.set(4);f=AwB(S);O=(c.bc=f,c.bih=M.height,c.biw=M.width,c.brdim=C.join(),c.vis=j0(O.K),c.wgl=!!f6.WebGLRenderingContext,c);h=V.call(h,k,O);h.ca_type="image";D&&(h.bid=D);return h};
        PN=function(D){var O={};O.dt=IoR;O.flash="0";a:{try{var h=D.D.top.location.href}catch(J){D=2;break a}D=h?h===D.K.location.href?0:1:2}O=(O.frm=D,O);try{O.u_tz=-(new Date).getTimezoneOffset();var V=V===void 0?f6:V;try{var k=V.history.length}catch(J){k=0}O.u_his=k;var C;O.u_h=(C=f6.screen)==null?void 0:C.height;var M;O.u_w=(M=f6.screen)==null?void 0:M.width;var c;O.u_ah=(c=f6.screen)==null?void 0:c.availHeight;var S;O.u_aw=(S=f6.screen)==null?void 0:S.availWidth;var Y;O.u_cd=(Y=f6.screen)==null?void 0:
        Y.colorDepth}catch(J){}return O};
        OSe=function(){if(!DwB)return null;var D=DwB();return"open"in D?D:null};
        g.a2=function(D){switch(R2(D)){case 200:case 201:case 202:case 203:case 204:case 205:case 206:case 304:return!0;default:return!1}};
        R2=function(D){return D&&"status"in D?D.status:-1};
        g.fc=function(D,O){typeof D==="function"&&(D=g.Cc(D));return window.setTimeout(D,O)};
        g.Kc=function(D,O){typeof D==="function"&&(D=g.Cc(D));return window.setInterval(D,O)};
        g.EP=function(D){window.clearTimeout(D)};
        g.jW=function(D){window.clearInterval(D)};
        g.AO=function(D){D=UP(D);return typeof D==="string"&&D==="false"?!1:!!D};
        g.G7=function(D,O){D=UP(D);return D===void 0&&O!==void 0?O:Number(D||0)};
        tO=function(){return g.OP("EXPERIMENTS_TOKEN","")};
        UP=function(D){return g.OP("EXPERIMENT_FLAGS",{})[D]};
        vN=function(){for(var D=[],O=g.OP("EXPERIMENTS_FORCED_FLAGS",{}),h=g.P(Object.keys(O)),V=h.next();!V.done;V=h.next())V=V.value,D.push({key:V,value:String(O[V])});h=g.OP("EXPERIMENT_FLAGS",{});V=g.P(Object.keys(h));for(var k=V.next();!k.done;k=V.next())k=k.value,k.startsWith("force_")&&O[k]===void 0&&D.push({key:k,value:String(h[k])});return D};
        QR=function(D,O,h,V,k,C,M,c){function S(){(Y&&"readyState"in Y?Y.readyState:0)===4&&O&&g.Cc(O)(Y)}
        h=h===void 0?"GET":h;V=V===void 0?"":V;c=c===void 0?!1:c;var Y=OSe();if(!Y)return null;"onloadend"in Y?Y.addEventListener("loadend",S,!1):Y.onreadystatechange=S;g.AO("debug_forward_web_query_parameters")&&(D=hJT(D,window.location.search));Y.open(h,D,!0);C&&(Y.responseType=C);M&&(Y.withCredentials=!0);h=h==="POST"&&(window.FormData===void 0||!(V instanceof FormData));if(k=VCw(D,k))for(var J in k)Y.setRequestHeader(J,k[J]),"content-type"===J.toLowerCase()&&(h=!1);h&&Y.setRequestHeader("Content-Type",
        "application/x-www-form-urlencoded");if(c&&"setAttributionReporting"in XMLHttpRequest.prototype){D={eventSourceEligible:!0,triggerEligible:!1};try{Y.setAttributionReporting(D)}catch(q){MB(q)}}Y.send(V);return Y};
        VCw=function(D,O){O=O===void 0?{}:O;var h=HN(D),V=g.OP("INNERTUBE_CLIENT_NAME"),k=g.AO("web_ajax_ignore_global_headers_if_set"),C;for(C in kxk){var M=g.OP(kxk[C]),c=C==="X-Goog-AuthUser"||C==="X-Goog-PageId";C!=="X-Goog-Visitor-Id"||M||(M=g.OP("VISITOR_DATA"));var S;if(!(S=!M)){if(!(S=h||(g.pH(D)?!1:!0))){S=D;var Y;if(Y=g.AO("add_auth_headers_to_remarketing_google_dot_com_ping")&&C==="Authorization"&&(V==="TVHTML5"||V==="TVHTML5_UNPLUGGED"||V==="TVHTML5_SIMPLY")&&x0d(S))S=yX(g.r7(5,S))||"",S=S.split("/"),
        S="/"+(S.length>1?S[1]:""),Y=S==="/pagead";S=Y?!0:!1}S=!S}S||k&&O[C]!==void 0||V==="TVHTML5_UNPLUGGED"&&c||(O[C]=M)}"X-Goog-EOM-Visitor-Id"in O&&"X-Goog-Visitor-Id"in O&&delete O["X-Goog-Visitor-Id"];if(h||!g.pH(D))O["X-YouTube-Utc-Offset"]=String(-(new Date).getTimezoneOffset());if(h||!g.pH(D)){try{var J=(new Intl.DateTimeFormat).resolvedOptions().timeZone}catch(q){}J&&(O["X-YouTube-Time-Zone"]=J)}document.location.hostname.endsWith("youtubeeducation.com")||!h&&g.pH(D)||(O["X-YouTube-Ad-Signals"]=
        cN(gt()));return O};
        MCR=function(D,O){var h=g.pH(D);g.AO("debug_handle_relative_url_for_query_forward_killswitch")||!h&&HN(D)&&(h=document.location.hostname);var V=yX(g.r7(5,D));V=(h=h&&(h.endsWith("youtube.com")||h.endsWith("youtube-nocookie.com")))&&V&&V.startsWith("/api/");if(!h||V)return D;var k=SW(O),C={};g.Je(Ct_,function(M){k[M]&&(C[M]=k[M])});
        r__
        """#
        
        let expectedJS = #"""
        {var O=D.split(D.slice(0,0)),h=[-427713130,1898166849,-1268610843,158454752,-1830992715,-1477369753,function(V,k){k=(k%V.length+V.length)%V.length;V.splice(k,1)},
        function(V,k){k.length!=0&&(V=(V%k.length+k.length)%k.length,k.splice(0,1,k.splice(V,1,k[0])[0]))},
        12618835,1031004894,function(){for(var V=64,k=[];++V-k.length-32;){switch(V){case 58:V-=14;case 91:case 92:case 93:continue;case 123:V=47;case 94:case 95:case 96:continue;case 46:V=95}k.push(String.fromCharCode(V))}return k},
        -326732465,-1764858234,function(){for(var V=64,k=[];++V-k.length-32;){switch(V){case 91:V=44;continue;case 123:V=65;break;case 65:V-=18;continue;case 58:V=96;continue;case 46:V=95}k.push(String.fromCharCode(V))}return k},
        -1531117326,788559869,1417713365,-1939999736,function(V,k,C,M,c,S,Y,J,q){return C(M,c,S,Y,J,q)},
        "[)//,,",O,1327600884,-2094972817,2030888738,function(V,k){k=(k%V.length+V.length)%V.length;V.splice(-k).reverse().forEach(function(C){V.unshift(C)})},
        133812157,2031205568,-1325399912,719172726,-1135157672,function(V){V.reverse()},
        function(V,k,C,M,c,S,Y,J){return k(C,M,c,S,Y,J)},
        O,1537557440,-1093417944,function(V,k,C,M,c,S,Y,J,q){return C(M,c,S,Y,J,q)},
        null,/'{\({\[]\)\\\(\(;/,1417713365,-1641363049,-1853774988,-1033263471,574263106,function(V){for(var k=V.length;k;)V.push(V.splice(--k,1)[0])},
        function(V,k,C,M,c,S){return k(M,c,S)},
        function(){for(var V=64,k=[];++V-k.length-32;)switch(V){case 46:V=95;default:k.push(String.fromCharCode(V));case 94:case 95:case 96:break;case 123:V-=76;case 92:case 93:continue;case 58:V=44;case 91:}return k},
        2011083848,null,-2084042919,820960604,-1061580952,-190965445,"oV-1",-1363898396,-1679223255,function(){for(var V=64,k=[];++V-k.length-32;)switch(V){case 58:V=96;continue;case 91:V=44;break;case 65:V=47;continue;case 46:V=153;case 123:V-=58;default:k.push(String.fromCharCode(V))}return k},
        1950885797,-356854457,161504232,-1754528998,function(V,k){if(V.length!=0){k=(k%V.length+V.length)%V.length;var C=V[0];V[0]=V[k];V[k]=C}},
        -582870620,1249279923,-1231993417,-1710862565,null,-380872291,"length",-1479526010,1440556590,-282702886,-631487905,1565478257,-50587191,function(V,k,C,M,c){return k(C,M,c)},
        O,1859562986,834790388,function(V,k,C){var M=k.length;C.forEach(function(c,S,Y){this.push(Y[S]=k[(k.indexOf(c)-k.indexOf(this[S])+S+M--)%k.length])},V.split(""))},
        1312889218,-1641363049,function(V,k){for(k=(k%V.length+V.length)%V.length;k--;)V.unshift(V.pop())},
        201460517];h[36]=h;h[47]=h;h[65]=h;if(typeof d0R==="undefined")return D;try{try{(h[64]==8||((((((0,h[6])(h[75],h[28]),h[7])(h[4],h[36]),h[60])(h[47],h[2]),h[81])(h[47],h[22]),h[78])(h[46],h[new Date("1969-12-31T14:46:15.000-09:15")/1E3]),""))&&(0,h[2])((0,h[15])((0,h[52])(h[74],h[11]),h[60],(0,h[49])(h[55],(0,h[67])(),h[3]),h[46],h[68]),h[45],(0,h[49])(h[23],(0,h[64])(),h[3]),h[1],h[7]),h[53]!==-1&&(h[22]<9||((0,h[78])(h[7],h[59]),0))&&(0,h[60])(h[3],h[79]),h[5]!==6&&(h[27]==new Date("1970-01-01T06:59:56.000+07:00")/
        1E3||((0,h[6])((0,h[45])(((0,h[61])(h[50],h[74]),h[49])(h[23],(0,h[26])(),h[74]),h[61],h[62],h[3]),((((0,h[78])(h[7],h[33]),h[80])(h[35],h[8]),(0,h[53])(h[59],(0,h[71])(),h[78]),h[18])(h[11]),h[17])(h[66],h[75]),h[33],(0,h[17])(h[59],h[60]),h[17],h[57],h[75]),0))&&((0,h[33])((0,h[33])((0,h[47])(h[42],h[36]),h[17],h[30],h[4]),h[18],h[75],h[68]),(0,h[64])(h[75]),((0,h[18])(h[32],h[31]),(0,h[18])(h[32],h[80]),h[18])(h[60],h[39]),(0,h[47])(h[32],h[49]),(0,h[29])(h[23],(0,h[62])(),h[32]),h[18])(h[71],
        h[34])}catch(V){(0,h[14])(h[42],h[46]),(0,h[18])(h[4],h[44]),(0,h[18])(h[32],h[81])}try{(h[69]<6||((0,h[33])((0,h[14])(h[32],h[38]),h[47],h[42],h[25]),0))&&((0,h[64])(h[60]),h[29])(h[23],(0,h[52])(),h[32])}catch(V){(0,h[29])(h[23],(0,h[11])(),h[4])}finally{h[48]!=9&&(0,h[14])(h[60],h[50]),h[62]!==1&&((0,h[39])((0,h[40])(h[18]),h[59],(0,h[6])(h[22],h[64]),h[46],h[53]),h[59])(h[74],h[48])}try{h[26]===8&&((0,h[0])((0,h[29])(h[19]),h[6],(0,h[73])((0,h[80])(h[46],h[52]),h[77],h[1],(0,h[12])(),h[19]),h[82],
        h[64]),1)||(0,h[34])((0,h[6])(h[28],h[19]),(0,h[80])(h[35],h[37]),h[66],(0,h[82])(h[38],h[28]),h[52],h[57],h[26]),(0,h[70])(h[16],(0,h[47])(),h[39]),(0,h[70])(h[77],(0,h[47])(),h[24])}catch(V){h[60]>=9&&(((((0,h[81])(h[67],h[16]),h[70])(h[44],(0,h[47])(),h[67]),h[22])(h[12]),h[76])((0,h[81])(h[12],h[48]),h[52],(0,h[2])(h[12],h[25]),h[12],h[59]),1)||(0,h[66])((0,h[76])((0,h[2])(h[12],h[51]),h[82],((0,h[35])(h[12]),(0,h[2])(h[28],h[3]),h[25])(h[51],h[32]),h[13],h[79]),h[75],h[79])}finally{(h[60]<6||
        ((0,h[7])(h[14]),void 0))&&(0,h[7])(h[30])}try{h[8]>=-6&&(0,h[59])((0,h[44])(h[18],h[8]),h[7],h[18]),h[81]<2&&((0,h[49])((0,h[56])(h[30],h[81]),h[73],(0,h[43])(h[61],h[58]),h[18],h[35]),"undefined")||(0,h[49])((0,h[44])(h[68],h[47]),h[55],(0,h[44])(h[68],h[63]),h[82],(0,h[37])(),h[30])}catch(V){((0,h[44])(h[58],h[67]),h[55])(h[82],(0,h[78])(),h[58])}}catch(V){return"4x_dwP_iOswhp0B-eL-_w8_"+D}return O.join("")}
        """#
        
        let extractedJSFunction = try Parser.findJavascriptFunctionFromStartpoint(html: html, startPoint: html.index(html.startIndex, offsetBy: 15))
        
        XCTAssertEqual(extractedJSFunction, expectedJS)
    }
    
    func testSimplerJavascriptFunctionExtractionSecondOvershootIssue() throws {
        
        let html = #"""
        c=[
        /'{\({\[]\)\\\(\(;/];
        some extra stuff
        """#
        
        let expectedJS = #"""
        [
        /'{\({\[]\)\\\(\(;/]
        """#
        
        let extractedJSFunction = try Parser.findJavascriptFunctionFromStartpoint(html: html, startPoint: html.index(html.startIndex, offsetBy: 2))
        
        XCTAssertEqual(extractedJSFunction, expectedJS)
        
    }
    
}
