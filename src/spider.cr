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
      sleep 1
      next unless comment
      puts "get page #{ i } done"
      comments.concat comment
      if i != b && i%100 === 0
        file = File.new "./pages/#{ i-100 }-#{ i }.json", "w"
        comments.to_json file
        comments = Array(Comment).new
      end
    end
  end
end

Spider.run(4000, 5000)
