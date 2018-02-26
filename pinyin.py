#!/usr/bin/python
# -*- coding: UTF-8 -*-

from pypinyin import pinyin, lazy_pinyin, Style
# print (pinyin(u'蹒跚',style=Style.FINALS))
import sqlite3

def search(temp):
	search_temp = temp.decode('utf-8')
	search_pinyin = pinyin(search_temp,style=Style.FINALS)
	# print search_pinyin
	conn = sqlite3.connect('c.db')
	c = conn.cursor()
	i = 1
	num = i*20
	cursor = c.execute("SELECT * from lyc limit "+str(num)+","+str(num+20))
	for row in cursor:
	    content = row[1]
	    lyc_name = row[6]
	    contents = content.split('|')
	    for item in contents:
	    	item_temp = item[-2:]
	    	pinyin_temp = pinyin(item,style=Style.FINALS)[-2:]
	    	if(search_pinyin == pinyin_temp):
	    		print u'歌曲:',lyc_name
	    		print item
	    		print '-----'
	conn.close()
# 
search('意思')

