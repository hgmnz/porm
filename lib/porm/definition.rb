module Porm
  class Table::Definition
    attr_accessor :columns
    def initialize(table_name, opts = {})
      @columns    = []
      @columns    << {:name => 'id', :type => 'serial primary key'} unless opts[:no_id]
      @table_name = table_name
    end

    def string(*args)
      constraint = args.last.kind_of?(Hash) ? args.pop : {}
      self.columns << { :name => args.first,
                        :type => 'character varying(255)',
                        :constraint => constraint_sql(constraint) }
    end

    def datetime(*args)
      self.columns << { :name => args.first,
        :type => 'timestamp without time zone' }
    end

    def boolean(*args)
      self.columns << { :name => args.first,
        :type => 'boolean' }
    end

    def integer(*args)
      constraint = args.last.kind_of?(Hash) ? args.pop : {}
      self.columns << { :name => args.first,
                        :type => 'integer',
                        :constraint => constraint_sql(constraint) }
    end

    def references(*args)
      self.columns << { :name       => "#{args.first}_id",
        :type       => 'integer',
        :constraint => "references #{Porm.tableize(args.first)}(id)"}
    end

    def to_sql
      sql = "alter table #{@table_name} "
      sql + self.columns.map do |column|
          "add column #{column[:name]} #{column[:type]} #{column[:constraint]}"
      end.join(', ')
    end

    def column_names
      self.columns.map { |column| column[:name]}
    end

    def constraint_sql(hash)
      sql = []
      if hash[:null] == false
        sql << "NOT NULL"
      end
      if hash[:unique] == true
        sql << "UNIQUE"
      end
      if hash[:check]
        sql << "CHECK ( #{hash[:check]} )"
      end
      sql.join(' ')
    end

  end
end
