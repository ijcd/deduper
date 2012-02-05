require 'sqlite3'

# TODO: add ability to gather index over ssh (ssh-root?)
module Deduper
  class Indexer

    attr_reader :db

    def initialize
      @db = Deduper::Database.new("test.db")
    end

    def hashsum(path)
      md5 = Digest::MD5.new
      sha1 = Digest::SHA1.new
      open(path, "r") do |io|
        counter = 0
        while (!io.eof)
          readBuf = io.readpartial(BUFLEN)
          md5.update(readBuf)
          sha1.update(readBuf)
        end
      end
      return [md5.hexdigest, sha1.hexdigest]
    end

    def index(path)
      Find.find(path) do |path|
        next unless File.file?(path)
        unless db.find_file(path).any?
          puts [path, File.size(path), *hashsum(path)].join(" ")
          db.add_file(path, File.size(path), *hashsum(path))
        end
      end
    end

  end
end
