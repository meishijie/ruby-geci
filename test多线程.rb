#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'
require 'timeout'
require 'enumerator'


  @nowarray  = []
  @alllist = []
  @database = 1
  $queue = []
  @data={}

  def insert(i)
    # 转成字符串存入数据库
    @data["_lrcname"] = '1'
    @data["_album"] = '1'
    @data["_albumLink"] = '1'
    @data["_artist"] = '1'
    @data["_artistLink"] = '1'
    @data["_lyccontent"] = i
    # 根据@database的名字不同 存入不同的数据库
    SQLite3::Database.new("test.db") do |db|
      db.execute("INSERT INTO lyc ( lycname , album , albumLink , artist , artistLink , lyccontent ) VALUES ('#{@data["_lrcname"]}' , '#{@data["_album"]}' , '#{@data["_albumLink"]}' , '#{@data["_artist"]}' , '#{@data["_artistLink"]}', '#{@data["_lyccontent"]}')")
      db.close
    end
  end


  # url 字母链接
  # database 字母(和数据库名字相关)： a b c ...
  
    
    28.times.each_slice(3) do |i|
      @alllist<<i
    end
    @alllist.each do |lists|
      puts "#{lists}--"
      $queue = lists
      puts "#{$queue}--"
      $queue.each do |i|
        # puts Thread.list.length()
        @nowarray<< Thread.new do
            xid = $queue.pop()
            insert xid
        end
      end
      @nowarray.each do |t|
        t.join
      end
    end




# run = Getlrc.new("http://www.kuwo.cn/geci/artist_a.htm")
# puts run.nowarray
# 还差一个 qita 分类没有下载 用run = Getlrc.new("http://www.kuwo.cn/geci/artist_qita.htm")

# 根据不同的字母 存入不同的数据库