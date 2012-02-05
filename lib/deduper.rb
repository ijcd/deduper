require "deduper/version"

require 'rubygems'
require 'find'
require 'digest/md5'
require 'digest/sha1'

autoload Deduper::Database, 'deduper/database'

module Deduper

  class Runner

    BUFLEN = 1024

    def hashsum(path)
      md5 = Digest::MD5.new
      sha1 = Digest::SHA1.new
      open(path, "r") do |io|
        counter = 0
        while (!io.eof)
          readBuf = io.readpartial($BUFLEN)
          md5.update(readBuf)
          sha1.update(readBuf)
        end
      end
      return [md5, sha1]
    end

    def run
      dirs = %w|/Users/ijcd/Archive|
      db = Deduper::Database.new("test.db")

      count = 0
      Find.find(dirs.first) do |path|
        unless db.find_file(path).any?
          puts [path, File.size(path), *hashsum(path)].join(" ")
          db.add_file(path, File.size(path), *hashsum(path))
        end
        count += 1
        exit if count >= 100
      end
    end
  end
end

Deduper::Runner.new.run

