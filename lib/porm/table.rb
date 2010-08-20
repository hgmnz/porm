module Porm
  module Table
    def self.included(base)
      klass = base.to_s
      base.extend ClassMethods
      class << base
        attr_accessor :table_name, :column_names, :superclass
      end
    end

    def save
      inserter = Porm::Table::Insertion.new(self.class.table_name)
      inserter.insert(properties)
      begin
        Porm.execute(inserter.to_sql)
        self
      rescue PGError => e
        if e.error =~ /ERROR:  insert or update on table .* violates foreign key constraint/
          false
        elsif e.error =~ /ERROR:  null value in column "\w+" violates not-null constraint/
          false
        elsif e.error =~ /ERROR:  duplicate key value violates unique constraint/
          false
        elsif e.error =~ /ERROR:  new row for relation "\w+" violates check constraint "\w+"/
          false
        else
          raise e
        end
      end
    end

    def properties
      self.class.column_names.inject({}) do |accum, column_name|
        accum[column_name] = self.send(column_name)
        accum
      end
    end

    module ClassMethods
      def attributes(&block)
        self.table_name = self.to_s.pluralize.downcase
        unless table_exists?
          Porm.execute(<<-SQL)
            create table #{table_name} () #{inheritance_clause};
          SQL
          table_definition = Porm::Table::Definition.new(table_name, :no_id => inherited?)
          block.call table_definition
          self.column_names = table_definition.column_names
          self.send(:attr_accessor, *table_definition.column_names)
          Porm.execute(table_definition.to_sql)
        end
      end

      def create(attributes)
        instance = self.build(attributes)
        if instance.save
          Porm::CreateSuccessProxy.new(instance)
        else
          Porm::CreateFailureProxy.new(instance)
        end
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
      alias :build :from_pgconn

      protected

      def table_exists?
        result = Porm.select(<<-SQL)
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

      def inherited(subclass)
        subclass.inherited_from!(self)
      end

      def inheritance_clause
        "inherits(#{Porm.tableize(superclass)})" if inherited?
      end

      def inherited?
        superclass
      end

      def inherited_from!(superclass)
        self.superclass = superclass
      end
    end
  end
end
