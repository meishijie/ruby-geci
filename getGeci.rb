#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'

class Getlrc

  def initialize(url)
    @nowarray  = []
    @manListId = []
    getManPage(url)
    getSong(url)
  end

  # 获取所有歌手的链接
  def getManPage(url)
    # 获取a b c d等
    urlId = url[31..url.length-5]
    # 获取所有manlist 放入数组
    html      =  RestClient.get(url).body
    doc       =  Nokogiri::HTML.parse(html)
    _lastPageUrl = doc.xpath('//*[@id="pageDiv"]/a[7]').attr('href').text
    _lastPageNum = _lastPageUrl[15..._lastPageUrl.length-4].to_i
    # 如果是其他 范围变小
    if urlId == "qita" then
      _lastPageNum = _lastPageUrl[18..._lastPageUrl.length-4].to_i
      puts _lastPageNum
    end
    (0..._lastPageNum).each do |i|
      puts "loading #{i+1}"
      getManList("http://www.kuwo.cn/geci/artist_#{urlId}_#{i}.htm")
    end
  end
  def getManList(url)
    # 获取所有歌手id  放入数组
    html  =  RestClient.get(url).body
    doc   =  Nokogiri::HTML.parse(html)
    doc.css('.songer_list > li').each do |li|
      str = li.>('a').attr('href').text
      str = str[26..str.length-2] # 把id号取出来放入数组 去掉这行就是把链接放入数组
      @manListId.push(str)
    end
  end

  # 获取所有歌手的歌曲 json格式
  def getSong(url)
    # 根据歌手列表每个id 获取id的所有歌曲
    @manListId.each do |manurl|
      # 获取歌手的总页数
      uri = "http://www.kuwo.cn/geci/wb/getJsonData?type=artSong&artistId=#{manurl}&page=1"
      html_response = nil
      open(uri) do |http|
        html_response = http.read
      end
      sleep 2
      totalpage = JSON.parse(html_response)["totalPage"]

      # 根据总页数 每页读取歌曲id
      page = 1
      while page <= totalpage do
        url = "http://www.kuwo.cn/geci/wb/getJsonData?type=artSong&artistId=#{manurl}&page=#{page}"
        open(url) do |http|
          html_response = http.read
        end
        sleep 2
        page = page + 1
        # http://www.kuwo.cn/yinyue/40079875
        allSongId = JSON.parse(html_response)["data"]
        allSongId.each do |item|
          url = "http://www.kuwo.cn/yinyue/#{item["rid"]}"
          puts url
          puts '解析歌词...'
          getOneLyc(url)
        end
      end
    end
    #
  end


  # 获取一首歌的歌词 存入数据库 "http://www.kuwo.cn/yinyue/6749207"
  def getOneLyc(url)
    # 读取所有歌词 放入 @data
    parseHtml(url)
    # 把 @data 插入数据库
    insert
    sleep 2
  end
  # 解析内容
  # url       :   链接地址
  # classname :   类名
  def parseHtml(url)
    html  =  RestClient.get(url).body
    doc   =  Nokogiri::HTML.parse(html)
    _lrcname    = doc.xpath('//*[@id="lrcName"]').text
    _album      = doc.xpath('//*[@id="musiclrc"]/div[1]/p[1]/span/a').text
    _albumLink  = doc.xpath('//*[@id="musiclrc"]/div[1]/p[1]/span/a').attr('href')
    _artist     = doc.xpath('//*[@id="musiclrc"]/div[1]/p[2]/span/a').text
    _artistLink = doc.xpath('//*[@id="musiclrc"]/div[1]/p[2]/span/a').attr('href')
    # 传入具体歌词类名 放入数组
    doc.css('.lrcItem').each do |lyctxt|
      @nowarray.push(lyctxt.text)
    end
    # 转成字符串存入数据库
    @data = {}
    @data["_lrcname"] = _lrcname
    @data["_album"] = _album
    @data["_albumLink"] = _albumLink.text
    @data["_artist"] = _artist
    @data["_artistLink"] = _artistLink.text
    @data["_lyccontent"] = @nowarray.join('|').delete("'") #注意内容中的单引号符号
  end
  # 插入数据库
  def insert
    SQLite3::Database.new("lyc.db") do |db|
      db.execute("INSERT INTO lyc ( lycname , album , albumLink , artist , artistLink , lyccontent ) VALUES ('#{@data["_lrcname"]}' , '#{@data["_album"]}' , '#{@data["_albumLink"]}' , '#{@data["_artist"]}' , '#{@data["_artistLink"]}', '#{@data["_lyccontent"]}')")
      db.close
    end
  end
end

# run = Getlrc.new("http://www.kuwo.cn/geci/artist_a.htm")
# puts run.nowarray
"abcdefghijklmnopqrstuvwxyz".each_char do |item|
  puts " -------------------#{item}组开始------------------------------ "
  run = Getlrc.new("http://www.kuwo.cn/geci/artist_#{item}.htm")
  sleep 3
end