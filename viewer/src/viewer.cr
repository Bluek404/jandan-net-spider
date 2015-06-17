require "json"
require "./viewer/*"
require "../../src/spider/comment"

module Viewer
  def self.run(dir)
    comments = Array(Spider::Comment).new
    Dir.foreach dir, do |f|
      next if f == "." || f == ".."
      next if File.directory? f
      next unless f =~ /.*.json/

      str = File.read dir+f
      json = Array(Spider::Comment).from_json str
      comments.concat json
    end
  end
end

dir = ARGV[0]
Viewer.run dir
