module Porm
  module Table
    def self.included(base)
      klass = base.to_s
      @@table_name = klass.pluralize.downcase
      base.extend ClassMethods
      base.cattr_accessor :table_name
    end

    module ClassMethods
      def attributes(&block)
        unless table_exists?
          Porm.connection.exec(<<-SQL)
            create table #{table_name}();
          SQL
          table_definition = Porm::Table::Definition.new(table_name)
          block.call table_definition
          self.send(:attr_accessor, *table_definition.column_names)
          Porm.connection.exec(table_definition.to_sql)
        end
      end

      def create(attributes)
        inserter = Porm::Table::Insertion.new(table_name)
        inserter.insert(attributes)
        Porm.connection.exec(inserter.to_sql)
      end

      def where(conditions)
        Porm::Scope.new(self, :conditions => conditions)
      end

      def from_pgconn(pg_result)
        object = self.new
        pg_result.each do |attribute, value|
          object.send("#{attribute}=", value)
        end
        object
      end

      protected
      def table_exists?
        result = Porm.connection.exec(<<-SQL)
          SELECT count(*)
          FROM pg_catalog.pg_class c
               LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind IN ('r','')
                AND n.nspname <> 'pg_catalog'
                AND n.nspname <> 'information_schema'
                AND n.nspname !~ '^pg_toast'
            AND pg_catalog.pg_table_is_visible(c.oid)
            AND c.relname = '#{self.table_name}';
        SQL
        result[0]['count'] == "1"
      end
    end

    class Insertion
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
        attributes.inject([]) { |acc, e| acc + e.keys }
      end

      def column_values
        attributes.inject([]) do |acc, e|
          acc + e.values.map { |value| Porm.sql_escape(value) }
        end
      end

    end

    class Definition
      attr_accessor :columns
      def initialize(table_name)
        @columns    = []
        @table_name = table_name
      end

      def string(*args)
        columns << { :name => args.first,
                     :type => 'character varying(255)' }
      end

      def datetime(*args)
        columns << { :name => args.first,
                     :type => 'timestamp without time zone' }
      end

      def to_sql
        sql = "alter table #{@table_name} "
        sql + @columns.map do |column|
          "add column #{column[:name]} #{column[:type]}"
        end.join(', ')
      end

      def column_names
        columns.map { |column| column[:name]}
      end

    end
  end
end
