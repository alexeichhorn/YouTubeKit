//
//  ParserTests.swift
//  YouTubeKit
//
//  Created by Alexander Eichhorn on 14.08.2024.
//

import XCTest
@testable import YouTubeKit

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
    
}
