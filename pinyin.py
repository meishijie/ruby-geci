#!/usr/bin/python
# -*- coding: UTF-8 -*-

from pypinyin import pinyin, lazy_pinyin, Style
# print (pinyin(u'蹒跚',style=Style.FINALS))
import sqlite3

search = '意义'

settemp = set(search.decode('utf-8'))
print settemp.decode('utf-8')
# search_temp = search.decode('utf-8')
# search_pinyin = pinyin(search_temp,style=Style.FINALS)
# # print search_pinyin

# conn = sqlite3.connect('c.db')
# c = conn.cursor()
# cursor = c.execute("SELECT *  from lyc")
# for row in cursor:
#     content = row[1]
#     lyc_name = row[6]
#     contents = content.split('|')
#     for item in contents:
#     	item_temp = item[-2:]
#     	pinyin_temp = pinyin(item,style=Style.FINALS)[-2:]
#     	if(search_pinyin == pinyin_temp):
#     		print u'歌曲:',lyc_name
#     		print item
#     		print '-----'
    		
#     		# print search_temp
#     		# print item_temp
#     		# print item_temp == "%s" % search.decode('utf-8')
#     		# print pinyin_temp
# conn.close()