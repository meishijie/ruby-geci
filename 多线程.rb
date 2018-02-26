#encoding:utf-8
require 'net/http'
require 'thread'
require 'open-uri'
require 'nokogiri'
require 'date'

$queue = Queue.new
#文章列表页数
page_nums = 8
page_nums.times do |num|
  $queue.push("http://www.cnblogs.com/hongfei/default.html?page="+num.to_s)
end

threads = []
#获取网页源码
def get_html(url)
  html = ""
  open(url) do |f|
    html = f.read
  end
  return html
end

def fetch_links(html)
  doc = Nokogiri::HTML(html)
  #提取文章链接
  doc.xpath('//div[@class="postTitle"]/a').each do |link|
    href = link['href'].to_s
    if href.include?"html"
      #add work to the  queue
      $queue.push(link['href'])
    end
  end
end

def save_to(save_to,content)
  f = File.new("./"+save_to+".html","w+")
  f.write(content)
  f.close()
end

#程序开始的时间
$total_time_begin = Time.now.to_i

#开辟的线程数
threadNums = 10
threadNums.times do
  threads<<Thread.new do
    until $queue.empty?
      url = $queue.pop(true) rescue nil
      html = get_html(url)
      fetch_links(html)
      if !url.include?"?page"
        title = Nokogiri::HTML(html).css('title').text
        puts "["+ Time.now.strftime("%H:%M:%S") + "]「" + title + "」" + url
        save_to("pages/" + title.gsub(/\//,""),html) if url.include?".html"
      end
    end
  end
end
threads.each{|t| t.join}

#程序结束的时间
$total_time_end = Time.now.to_i
puts "线程数：" + threadNums.to_s
puts "执行时间：" + ($total_time_end - $total_time_begin).to_s + "秒"