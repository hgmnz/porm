require 'rubygems'
require 'active_support'
require File.expand_path('porm/table', File.dirname(__FILE__))
require File.expand_path('porm/scope', File.dirname(__FILE__))

module Porm
  extend self
  def connection
    @pg_conn
  end

  def connection=(connection)
    @pg_conn = connection
  end

  def sql_escape(string)
    "E'#{string}'"
  end
end
