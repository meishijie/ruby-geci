#-*- code:utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'sqlite3'
require 'json'
require 'timeout'

class Getlrc

  # url 字母链接
  # database 字母(和数据库名字相关)： a b c ...
  def initialize(url,database)
    @nowarray  = []
    @manListId = []
    @database = database
    getManPage(url)
    getSong(url)
  end

  # 获取所有歌手的链接
  def getManPage(url)
    # 获取a b c d等
    urlId = url[31..url.length-5]
    # 获取所有manlist 放入数组
    begin
      html  =  RestClient.get(url).body
    rescue
      retry
    end

    doc  =  Nokogiri::HTML.parse(html)
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
    begin
      html  =  RestClient.get(url).body
    rescue
      retry
    end
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
      # 处理超时异常 重新连接
      begin
        open(uri) do |http|
          html_response = http.read
        end
      rescue
        puts '超时 重新连接'
        retry
      end

      totalpage = /totalPage":[\d]+/.match(html_response).to_s.delete('totalPage":')
      #
      page = 1
      while page <= totalpage.to_i do
        uri = "http://www.kuwo.cn/geci/wb/getJsonData?type=artSong&artistId=#{manurl}&page=#{page}"
        html_response = nil

        # 处理超时异常
        begin
          open(uri) do |http|
            html_response = http.read
          end
        rescue
          puts '超时 重新连接'
          retry
        end

        allSongUrl = html_response.scan(/rid":"[\d]+/) #/rid":"[\d]+"/.match(html_response)
        allSongUrl = allSongUrl.map do |item|
          item.delete('rid":"')
        end
        allSongUrl.each do |item|
          url = "http://www.kuwo.cn/yinyue/#{item}"
          getOneLyc(url)
        end
        puts "totalpage #{totalpage}"
        puts "curruntPage #{page}"
        page = page + 1
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
    # sleep 1
  end


  # 解析内容
  # url       :   链接地址
  # classname :   类名
  def parseHtml(url)
    @data = {}
    @nowarray = []
    @url = url
    begin
      html  =  RestClient::Request.execute(method: :get, url: url, timeout: 60).body
    rescue
      puts '连接超时 重试'
      retry
    end

    # puts html
    doc   =  Nokogiri::HTML.parse(html)
    # 注意：： 没有获取到歌词 退出  有些页面没有歌词 以及版权问题 不显示歌词
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
    @data["_lyccontent"] = @nowarray.join('|')
    #注意内容中的单引号等符号
    @data["_lyccontent"] = @data["_lyccontent"].gsub(/['"\\\*&.?!,…:;]/, '')
  end
  # 插入数据库
  def insert
    # 没有歌词的时候就不存入数据库
    if @data.has_key?("_lyccontent") then
      if @data["_lyccontent"].length < 20 then
        puts "#{@url}没有具体文字内容"
        return
      else
        #注意内容中的单引号等符号
        lydata = @data["_lyccontent"].gsub(/['"\\\*&.?!,…:;]/, '')
        # 根据@database的名字不同 存入不同的数据库
        SQLite3::Database.new("#{@database}.db") do |db|
          db.execute("INSERT INTO lyc ( lycname , album , albumLink , artist , artistLink , lyccontent ) VALUES ('#{@data["_lrcname"]}' , '#{@data["_album"]}' , '#{@data["_albumLink"]}' , '#{@data["_artist"]}' , '#{@data["_artistLink"]}', '#{lydata}')")
          db.close
        end
      end
    else
      # puts @data["_lyccontent"]
      return
    end
  end

end

# run = Getlrc.new("http://www.kuwo.cn/geci/artist_a.htm")
# puts run.nowarray
# 还差一个 qita 分类没有下载 用run = Getlrc.new("http://www.kuwo.cn/geci/artist_qita.htm")

# 根据不同的字母 存入不同的数据库
"k".each_char do |item|
  puts " -----#{item}组开始------- "
  Getlrc.new("http://www.kuwo.cn/geci/artist_#{item}.htm",item)
end