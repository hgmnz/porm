require 'rubygems'
require 'active_support'
require File.expand_path('porm/table', File.dirname(__FILE__))
require File.expand_path('porm/scope', File.dirname(__FILE__))
require File.expand_path('porm/create_success_proxy', File.dirname(__FILE__))
require File.expand_path('porm/create_failure_proxy', File.dirname(__FILE__))
require File.expand_path('porm/definition', File.dirname(__FILE__))
require File.expand_path('porm/insertion', File.dirname(__FILE__))

module Porm
  extend self
  def connection
    @pg_conn
  end

  def connection=(connection)
    @pg_conn = connection
  end

  def sql_escape(stringish)
    if stringish.nil?
      "NULL"
    else
      "E'#{stringish.to_s}'"
    end
  end

  def execute(sql)
    connection.exec(sql)
  end
  alias :select :execute

  def tableize(s)
    s.to_s.downcase.pluralize
  end

end
