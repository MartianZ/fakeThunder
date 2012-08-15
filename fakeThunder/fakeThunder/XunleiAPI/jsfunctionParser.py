# jsonParser.py
#
# Implementation of a simple JSON parser, returning a hierarchical
# ParseResults object support both list- and dict-style data access.
#
# Copyright 2006, by Paul McGuire
#
# Updated 8 Jan 2007 - fixed dict grouping bug, and made elements and
#   members optional in array and object collections
#
json_bnf = """
object 
    { members } 
    {} 
members 
    string : value 
    members , string : value 
array 
    [ elements ]
    [] 
elements 
    value 
    elements , value 
value 
    string
    number
    object
    array
    true
    false
    null
"""

import json
from pyparsing import *

TRUE = Keyword("true").setParseAction( replaceWith(True) )
FALSE = Keyword("false").setParseAction( replaceWith(False) )
NULL = Keyword("null").setParseAction( replaceWith(None) )

def string_parse(toks):
    return map(json.loads, ['"%s"' % tok.strip("'\"").replace("\\'", "'") for tok in toks])

jsonString = quotedString.setParseAction( string_parse )
jsonNumber = Combine( Optional('-') + ( '0' | Word('123456789',nums) ) +
                    Optional( '.' + Word(nums) ) +
                    Optional( Word('eE',exact=1) + Word(nums+'+-',nums) ) )

jsonObject = Forward()
jsonArray = Forward()
jsonValue = Forward()
jsonElements = delimitedList( jsonValue )
jsonArray1 = Group(Suppress('[') + Optional(jsonElements) + Suppress(']') )
jsonArray2 = Group(Suppress(CaselessLiteral('new'))+Suppress(White())+Suppress(CaselessLiteral('array(')) + Optional(jsonElements) + Suppress(')') )
jsonArray << ( jsonArray1 | jsonArray2 )
jsonValue << ( jsonString | jsonNumber | jsonObject | jsonArray | TRUE | FALSE | NULL )
memberDef = Group( jsonString + Suppress(':') + jsonValue )
jsonMembers = delimitedList( memberDef )
jsonObject << Dict( Suppress('{') + Optional(jsonMembers) + Suppress('}') )
jsFunctionName = Word(alphas + "_.",  alphanums + "_.")
jsFunctionCall = Suppress(Optional(CaselessLiteral("<script>"))) + \
                    Optional(jsFunctionName, Empty()) + Suppress(Optional("(")) + \
                        Group(Optional(jsonElements)) + \
                    Suppress(Optional(")"+";")) + \
                 Suppress(Optional(CaselessLiteral("</script>")))

def convertNumbers(s,l,toks):
    n = toks[0]
    try:
        return int(n)
    except ValueError, ve:
        return float(n)

def convertDict(toks):
    result = {}
    for each in toks:
        result[each[0]] = each[1]
    return result

def convertList(toks):
    result = []
    for each in toks:
        result.append(each.asList())
    return result

def call_json(toks):
    return map(json.loads, toks)

jsonNumber.setParseAction( convertNumbers )
jsonObject.setParseAction( convertDict )
jsonArray.setParseAction( convertList )

def parser_js_function_call(string):
    return jsFunctionCall.parseString(string.lstrip('\xef\xbf\xbb')).asList()
    
if __name__ == "__main__":
    testdata = """queryUrl(1,'3BC3BEC436094736BF19350711D4A5556F4B7536','123806924','[Dymy][Nurarihyon_no_Mago_Sennen_Makyou][18v2][BIG5][RV10][848x480].rmvb','0',new Array('[Dymy][Nurarihyon_no_Mago_Sennen_Makyou][18v2][BIG5][RV10][848x480].rmvb'),new Array('118M'),new Array('123806924'),new Array('1'),new Array('RMVB'),new Array('0'),'13206731991951250210.5123566347')"""
    testdata1 = """ queryCid("bt:\/\/3547930B96AFA7B0A1CFCC80D516ADE97A34DAE0\/0", '4E1FA9C76605CA8E77DD35DA08D817617403BF26', '87B9431F2F5606721BD761FAA5638A809DAF3080', '8055706', 'hbzz.rar', 0, 0, 0,'13206731991951250210.5123566347','rar')"""
    testdata2 = """ parent.begin_task_batch_resp()"""
    testdata3 = """fill_bt_list({"Result":{"Tid":"33684635655","Infoid":"3547930B96AFA7B0A1CFCC80D516ADE97A34DAE0","Record":[{"id":0,"title":"[AngelSub][Guilty Crown][04][FULLHD][BIG5][x264_AC3].mkv","download_status":"1","cid":"DCA5280E5072F48A2D0059F9BD00077395542202","size":"610M","percent":85.8,"taskid":"33684635975","icon":"RMVB","livetime":"7\u5929","downurl":"","vod":"0","cdn":[],"format_img":"video","filesize":"640205218","verify":"","url":"bt:\/\/3547930B96AFA7B0A1CFCC80D516ADE97A34DAE0\/0","openformat":"movie","ext":"mkv","dirtitle":"[AngelSub][Guilty Crown][04][FULLHD][BIG5][x264_AC3].mkv"}]}})"""
    failed_testdata4 = "queryUrl(-1,'F7E1170B7E18E23EDCB89DA7E97E2A8EBCB99532','252805207','[\xe5\xa4\xa9\xe4\xbd\xbf\xe5\x8a\xa8\xe6\xbc\xab][111111]\xe5\x88\x9d\xe9\x9f\xb3\xe3\x83\x9f\xe3\x82\xaf2011 - 39\\'s LIVE IN SINGAPORE[320K].rar','0',new Array('[\xe5\xa4\xa9\xe4\xbd\xbf\xe5\x8a\xa8\xe6\xbc\xab][111111]\xe5\x88\x9d\xe9\x9f\xb3\xe3\x83\x9f\xe3\x82\xaf2011 - 39\\'s LIVE IN SINGAPORE[320K].rar'),new Array('241M'),new Array('252805207'),new Array('1'),new Array('RAR'),new Array('0'),'13211232980911486034.96672')"    
    testdata5 = """{"Result":{"Tid":"33684635655","Infoid":"3547930B96AFA7B0A1CFCC80D516ADE97A34DAE0","Record":[{"id":0,"title":"[AngelSub][Guilty Crown][04][FULLHD][BIG5][x264_AC3].mkv","download_status":"1","cid":"DCA5280E5072F48A2D0059F9BD00077395542202","size":"610M","percent":85.8,"taskid":"33684635975","icon":"RMVB","livetime":"7\u5929","downurl":"","vod":"0","cdn":[],"format_img":"video","filesize":"640205218","verify":"","url":"bt:\/\/3547930B96AFA7B0A1CFCC80D516ADE97A34DAE0\/0","openformat":"movie","ext":"mkv","dirtitle":"[AngelSub][Guilty Crown][04][FULLHD][BIG5][x264_AC3].mkv"}]}}"""
    import pprint
    pprint.pprint( parser_js_function_call(testdata) )
    pprint.pprint( parser_js_function_call(testdata1) )
    pprint.pprint( parser_js_function_call(testdata2) )
    pprint.pprint( parser_js_function_call(testdata3) )
    pprint.pprint( parser_js_function_call(failed_testdata4) )
    pprint.pprint( parser_js_function_call(testdata5) )
