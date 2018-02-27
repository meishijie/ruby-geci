#!/usr/bin/python
# -*- coding: UTF-8 -*-
from pypinyin import pinyin, lazy_pinyin, Style
# print (pinyin(u'蹒跚',style=Style.FINALS))
import sqlite3

# 删除重复数据
# --DELETE FROM lyc WHERE rowid NOT IN(SELECT Max(rowid) rowid FROM lyc GROUP BY lycname)
# VACUUM
conn = sqlite3.connect('e.db')
c = conn.cursor()
c.execute("DELETE FROM lyc WHERE rowid NOT IN(SELECT Max(rowid) rowid FROM lyc GROUP BY lycname)")
conn.execute("VACUUM")
conn.commit()
conn.close()
