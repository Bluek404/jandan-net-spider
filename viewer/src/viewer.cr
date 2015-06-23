require "json"
require "./viewer/*"
require "../../src/spider/comment"
require "sqlite3"

module Viewer
  def self.run(dir)
    db = SQLite3::Database.new "data.db"
    db.execute %{
      CREATE TABLE IF NOT EXISTS comments (
        content VARCHAR(2048),
        oo      INT,
        xx      INT)}
    ins_stmt = db.prepare %{
      INSERT INTO comments
      VALUES (?, ?, ?)}
    comments = Array(Spider::Comment).new
    Dir.foreach(dir) do |f|
      next if f == "." || f == ".."
      next if File.directory? f
      next unless f =~ /.*.json/

      str = File.read dir+f
      json = Array(Spider::Comment).from_json str
      comments.concat json
    end
    comments.each do |comment|
      p comment.content
      result_set = ins_stmt.execute comment.content, comment.oo, comment.xx
      result_set.next
    end
    ins_stmt.close
    db.close
  end
end

dir = ARGV[0]
Viewer.run dir
