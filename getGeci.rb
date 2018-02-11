#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'iconv'
require 'sqlite3'
class Getlrc
  def initialize
    @nowarray = []
    parseHtml("http://www.kuwo.cn/yinyue/6749207", '.lrcItem')
    insert
  end

  # 抓取一首歌的歌词 解析内容
  # url       :   链接地址
  # classname :   类名
  def parseHtml(url, cname)
    html = RestClient.get(url).body
    doc = Nokogiri::HTML.parse(html)
    # puts doc
    _lrcname = doc.xpath('//*[@id="lrcName"]').text
    _album = doc.xpath('//*[@id="musiclrc"]/div[1]/p[1]/span/a').text
    _albumLink = doc.xpath('//*[@id="musiclrc"]/div[1]/p[1]/span/a').attr('href')
    _artist = doc.xpath('//*[@id="musiclrc"]/div[1]/p[2]/span/a').text
    _artistLink = doc.xpath('//*[@id="musiclrc"]/div[1]/p[2]/span/a').attr('href')
    # puts _lrcname,_album,_albumLink,_artist,_artistLink
    # 传入类名 放入数组
    doc.css(cname).each do |lyctxt|
      @nowarray.push(lyctxt.text)
    end
    # 转成字符串存入数据库US-ASCII
    # @nowarray.join(',')
    @data = {}
    @data["_lrcname"] = _lrcname
    @data["_album"] = _album
    @data["_albumLink"] = _albumLink.text
    @data["_artist"] = _artist
    @data["_artistLink"] = _artistLink.text
    @data["_lyccontent"] = @nowarray.join('|')
  end

  def nowarray()
    @nowarray.join('|')
  end

  def insert

    SQLite3::Database.new("lyc.db") do |db|
      db.execute("INSERT INTO lyc ( lycname , album , albumLink , artist , artistLink , lyccontent ) VALUES ('#{@data["_lrcname"]}' , '#{@data["_album"]}' , '#{@data["_albumLink"]}' , '#{@data["_artist"]}' , '#{@data["_artistLink"]}', '#{@data["_lyccontent"]}' )")
      db.close
    end

    # db = SQLite3::Database.new("lyc.db")
    # # INSERT INTO Websites (name, country)
    # db.execute("INSERT INTO lyc ( lycname ) VALUES (#{@data["_lycname"]})") do |row|
    #   p row
    # end

  end

end

run = Getlrc.new()
# puts run.nowarray
