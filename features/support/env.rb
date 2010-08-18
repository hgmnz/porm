require 'pg'
require 'tempfile'
require 'ruby-debug'
require 'lib/porm'

Porm.connection = PGconn.open(:dbname => 'porm_test')
Before do
  puts "running Before"
  all_tables.each do |table_name|
    Porm.execute("drop table #{table_name};")
  end
end

at_exit do
  Porm.connection.close
end

def all_tables
  Porm.select(<<-SQL).map { |row| row["Name"] }
    SELECT c.relname as "Name"
    FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r','')
          AND n.nspname <> 'pg_catalog'
          AND n.nspname <> 'information_schema'
          AND n.nspname !~ '^pg_toast'
      AND pg_catalog.pg_table_is_visible(c.oid)
  SQL
end
