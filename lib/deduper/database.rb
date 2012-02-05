require 'sqlite3'

# TODO: ability to merge remote indexes
# TODO: path to files and their index
module Deduper
  class Database < SQLite3::Database
    def initialize(path)
      super
      if table_info("files").empty?
        execute_batch(<<-SQL)
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

      @insert_file = prepare("insert into files (path, size, md5, sha1) values (?, ?, ?, ?)")
      @find_file =   prepare("select * from files where path = ?")
    end

    def add_file(path, size, md5, sha1)
      @insert_file.execute(path, size, md5, sha1)
    end

    def find_file(path)
      @find_file.execute(path)
    end

    # produce groupings of similar files
    def find_similar_files
      "SELECT * FROM files 
         WHERE md5 = md5 AND sha1 = sha1 AND size = size
         GROUP BY md5, sha1, size"
    end

    # do a byte-by-byte check
    def find_same_files
      # loop over find_similar_files groups
      # diff -b file1 file2
    end
  end
end
