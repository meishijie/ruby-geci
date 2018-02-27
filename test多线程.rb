#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'
require 'timeout'
require 'enumerator'


  # url 字母链接
  # database 字母(和数据库名字相关)： a b c ...
  
    @nowarray  = []
    @alllist = []
    @database = 1
    $queue = []
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
        end
      end
      @nowarray.each do |t|
        t.join
      end
    end
 
  def insert    
        
        # # 根据@database的名字不同 存入不同的数据库
        # SQLite3::Database.new("z.db") do |db|
        #   db.execute("INSERT INTO lyc ( lycname , album , albumLink , artist , artistLink , lyccontent ) VALUES ('#{@data["_lrcname"]}' , '#{@data["_album"]}' , '#{@data["_albumLink"]}' , '#{@data["_artist"]}' , '#{@data["_artistLink"]}', '#{lydata}')")
        #   db.close
        # end
  end



# run = Getlrc.new("http://www.kuwo.cn/geci/artist_a.htm")
# puts run.nowarray
# 还差一个 qita 分类没有下载 用run = Getlrc.new("http://www.kuwo.cn/geci/artist_qita.htm")

# 根据不同的字母 存入不同的数据库

  puts " -----1组开始------- "
  insert 