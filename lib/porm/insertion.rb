module Porm
  class Table::Insertion
    attr_accessor :table_name, :attributes

    def initialize(table_name)
      self.table_name = table_name
      self.attributes = []
    end

    def insert(attributes)
      self.attributes = attributes.map { |k, v| { k => v } }
    end

    def to_sql
        "insert into #{table_name} (#{column_names.join(',')}) values (#{column_values.join(',')})"
    end

    private
    def column_names
      attributes.reject{|e| e.keys == ['id']}.inject([]) { |acc, e| acc + e.keys }
    end

    def column_values
      attributes.reject{|e| e.keys == ['id']}.inject([]) do |acc, e|
        acc + e.values.map { |value| Porm.sql_escape(value) }
      end
    end

  end
end
