#!/usr/bin/ruby

require 'rubygems'
require 'find'
require 'digest/md5'
require 'digest/sha1'
require 'sqlite3'

dirs = %w|/Users/ijcd/Archive|

$BUFLEN = 1024

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

def init_database
    db = SQLite3::Database.new( "test.db" )
    if db.table_info("files").empty?
        db.execute_batch(<<-SQL)
create table if not exists files (
  path varchar2(1024),
  size int(15),
  md5  varchar(64),
  sha1 varchar(64)
);
create index if not exists files_all  on files (path, md5, sha1, size);
create unique index if not exists files_path on files (path);
create index if not exists files_size on files (size);
create index if not exists files_md5  on files (md5);
create index if not exists files_sha1 on files (sha1);
        SQL
    end
    db
end

db = init_database

insert_file_stmt = db.prepare("insert into files (path, size, md5, sha1) values (?, ?, ?, ?)")
find_file_stmt = db.prepare("select * from files where path = ?")

count = 0
Find.find(dirs.first) do |path|
    unless find_file_stmt.execute(path).any?
        puts [path, File.size(path), *hashsum(path)].join(" ")
        insert_file_stmt.execute( path, File.size(path), *hashsum(path) )
    end
    count += 1
    exit if count >= 100
end
