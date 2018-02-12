#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'
# db = SQLite3::Database.new("lyc.db")
# db.execute("select * from lyc") do |row|
# 	p row
# end
# db.close

def parseHtml(url)
	@data = {}
	puts @data.length
	html  =  RestClient.get(url).body
	doc   =  Nokogiri::HTML.parse(html)
	# 没有获取到歌词 退出
	puts doc.css('.lrcItem').empty?
	# 没有获取到歌词 退出
	return if doc.css('.lrcItem').empty?
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
	@data["_lrcname"] = _lrcname
	@data["_album"] = _album
	@data["_albumLink"] = _albumLink.text
	@data["_artist"] = _artist
	@data["_artistLink"] = _artistLink.text
	@data["_lyccontent"] = @nowarray.join('|').delete("'") #注意内容中的单引号符号
end

parseHtml('http://www.kuwo.cn/yinyue/11589312')