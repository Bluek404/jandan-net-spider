require "http/client"
require "json"
require "./spider/*"

module Spider
  @@find_comment = %r(<li id="comment-[0-9]*">[\w\W]{0,}?<p[^>]*>([\w\W]{0,}?)</p>[\w\W]{0,}?\[<span id="cos_support-[0-9]*">([0-9]*)</span>\][\w\W]{0,}?\[<span id="cos_unsupport-[0-9]*">([0-9]*)</span>\][\w\W]{0,}?</li>)
  @@headers = HTTP::Headers.new
  @@headers["accept-language"] = "zh-cn,zh;q=0.8"
  @@headers["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  @@headers["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.125 Safari/537.36"

  struct Comment
    property content
    property oo
    property xx

    def initialize(@content, @oo, @xx)
    end

    def to_json(io)
      c = @content.clone.gsub("\"", "\\\"").gsub("\n", "")
      io << %({"content":"#{ c }","oo":#{ oo },"xx":#{ xx }})
    end
  end

  private def self.get_comments(page)
    body = HTTP::Client.get("http://jandan.net/pic/page-" + page.to_s, @@headers).body

    comments = Array(Comment).new
    i = body.index "<li id=\"comment-" # 从第一个评论开始查找
    return unless i
    loop do
      comment = @@find_comment.match body, i
      unless comment
        break
      end
      i += comment[0].bytesize
      comments << Comment.new(comment[1], comment[2], comment[3])
    end

    comments
  end

  def self.run(b, e)
    unless File.exists?("./pages")
      Dir.mkdir("./pages")
    end
    comments = Array(Comment).new
    (b..e).each do |i|
      comment = get_comments(i)
      next unless comment
      puts "get page #{ i } done"
      comments.concat comment
      if i != b && (i+1)%50 === 0
        file = File.new "./pages/#{ i+1-50 }-#{ i }.json", "w"
        comments.to_json file
        comments = Array(Comment).new
        sleep 50 # 休息，防止被封IP
      end
    end
  end
end
begin
  if ARGV.size != 2
    puts "需要指定起始页"
  end
  b = ARGV[0].to_i
  if b%50 != 0
    puts "起始页必须为50的倍数"
    exit
  end
  e = ARGV[1].to_i
  if (e+1)%50 != 0
    puts "终止页+1必须为50的倍数"
    exit
  end
rescue
  puts "参数必须为数字"
  exit
end
Spider.run(b, e)
