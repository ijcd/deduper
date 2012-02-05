require "deduper/version"

require 'pp'
require 'rubygems'
require 'find'
require 'digest/md5'
require 'digest/sha1'

module Deduper

  autoload :Database, 'deduper/database'
  autoload :Indexer, 'deduper/indexer'

  class Runner
    BUFLEN = 1024

    def die(msg)
      $stderr.puts "Error: #{msg}"
      exit 1
    end

    def run(paths=nil)
      paths ||= ARGV
      die "No paths given..." if paths.empty?

      indexer = Indexer.new

      paths.each do |path|
        indexer.index(path)
      end
    end
  end
end

