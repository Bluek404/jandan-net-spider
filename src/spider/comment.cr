require "json"

struct Spider::Comment
  property content
  property oo
  property xx

  def initialize(@content, @oo, @xx)
  end
  def initialize(pull: JSON::PullParser)
    pull.read_object do |key|
      case key
      when "content"
        @content = pull.read_string
      when "oo"
        @oo = pull.read_int
      when "xx"
        @xx = pull.read_int
      end
    end
  end

  def to_json(io)
    c = @content.to_json
    io << %({"content":"#{ c }","oo":#{ oo },"xx":#{ xx }})
  end
end
