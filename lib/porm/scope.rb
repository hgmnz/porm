module Porm
  class Scope
    attr_accessor :klass, :conditions
    def initialize(klass, options)
      self.klass = klass
      self.conditions = options[:conditions]
    end

    def method_missing(meth, *args)
      results = Porm.connection.exec(to_sql)
      list = results.map {|e| self.klass.from_pgconn(e)}
      list.send(meth, *args)
    end

    private
    def to_sql
      "select * from #{self.klass.table_name} where #{where_clause}"
    end

    def where_clause
      self.conditions.inject("") do |accum, (field_name, field_value)|
        accum + field_name.to_s + " = " + Porm.sql_escape(field_value)
      end
    end

  end
end
