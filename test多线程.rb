#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'
require 'timeout'



  # url 字母链接
  # database 字母(和数据库名字相关)： a b c ...
  
    @nowarray  = []
    @manListId = []
    @database = 1
    $queue = []
    10.times do |i|
      $queue.push(i)
    end
    
    # puts $queue
    #开辟的线程数
    threadNums = 2
    threadNums.times do |i|
      t = Thread.new do
        
        until $queue.empty?
          xid = $queue.pop()
          puts xid
        end
      end
      t.join
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