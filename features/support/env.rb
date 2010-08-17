require 'pg'
require 'tempfile'
require 'ruby-debug'
require 'lib/porm'

postgres_connection = PGconn.open(:dbname => 'postgres')
postgres_connection.exec('drop database if exists porm_test')
postgres_connection.exec('create database porm_test')
postgres_connection.close

Porm.connection = PGconn.open(:dbname => 'porm_test')
PG_CONN = Porm.connection

at_exit do
  PG_CONN.close
end