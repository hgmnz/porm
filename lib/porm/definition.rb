module Porm
  class Table::Definition
    attr_accessor :columns
    def initialize(table_name, opts = {})
      @columns    = []
      @columns    << {:name => 'id', :type => 'serial primary key'} unless opts[:no_id]
      @table_name = table_name
    end

    def string(*args)
      constraints = extract_constraints_from(args)
      options     = extract_character_options_from(args)
      type = "character varying"
      type = type + "(#{options[:length]})" if options[:length]
      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
    end

    def boolean(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'boolean',
                        :constraint => constraint_sql(constraints) }
    end

    def integer(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'integer',
                        :constraint => constraint_sql(constraints) }
    end

    def smallint(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'smallint',
                        :constraint => constraint_sql(constraints) }
    end

    def bigint(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'bigint',
                        :constraint => constraint_sql(constraints) }
    end

    def numeric(*args)
      constraints = extract_constraints_from(args)
      options     = extract_numeric_options_from(args)
      options[:scale] ||= 0
      type = "numeric(#{options[:precision]}"
      type = type + ", #{options[:scale]})"

      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
    end
    alias :decimal :numeric

    def char(*args)
      constraints = extract_constraints_from(args)
      options     = extract_character_options_from(args)
      type = "character"
      type = type + "(#{options[:length]})" if options[:length]
      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
    end
    alias :character :char

    def real(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'real',
                        :constraint => constraint_sql(constraints) }
    end

    def double(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'double precision',
                        :constraint => constraint_sql(constraints) }
    end

    def money(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'money',
                        :constraint => constraint_sql(constraints) }
    end

    def text(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'text',
                        :constraint => constraint_sql(constraints) }
    end

    def binary(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'bytea',
                        :constraint => constraint_sql(constraints) }
    end

    def timestamp(*args)
      constraints = extract_constraints_from(args)
      options     = extract_timestamp_options_from(args)
      options[:timezone] ||= false
      type = "timestamp "
      if options[:precision]
        type = type + "(#{options[:precision]}) "
      end
      if options[:timezone]
        type = type + "with time zone"
      else
        type = type + "without time zone"
      end
      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
    end
    alias :datetime :timestamp

    def date(*args)
      constraints = extract_constraints_from(args)
      self.columns << { :name       => args.first,
                        :type       => 'date',
                        :constraint => constraint_sql(constraints) }
    end

    def time(*args)
      constraints = extract_constraints_from(args)
      options     = extract_timestamp_options_from(args)
      options[:timezone] ||= false
      type = "time "
      if options[:precision]
        type = type + "(#{options[:precision]}) "
      end
      if options[:timezone]
        type = type + "with time zone"
      else
        type = type + "without time zone"
      end
      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
    end

    def interval(*args)
      constraints = extract_constraints_from(args)
      options     = extract_interval_options_from(args)
      options[:timezone] ||= false
      type = "interval "
      if options[:precision]
        type = type + "(#{options[:precision]}) "
      end
      self.columns << { :name       => args.first,
                        :type       => type,
                        :constraint => constraint_sql(constraints) }
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

    private
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

    CONSTRAINT_KEYS = [:null, :unique, :check]
    def extract_constraints_from(args)
      hash = args.last.kind_of?(Hash) ? args.last : {}
      Hash[hash.select { |k, v| CONSTRAINT_KEYS.include?(k) }]
    end

    OPTION_KEYS = [:precision, :scale]
    def extract_numeric_options_from(args)
      hash = args.last.kind_of?(Hash) ? args.last : {}
      Hash[hash.select { |k, v| OPTION_KEYS.include?(k) }]
    end

    def extract_character_options_from(args)
      hash = args.last.kind_of?(Hash) ? args.last : {}
      Hash[hash.select { |k, v| :length == k }]
    end

    TIMEZONE_KEYS = [:timezone, :precision]
    def extract_timestamp_options_from(args)
      hash = args.last.kind_of?(Hash) ? args.last : {}
      Hash[hash.select { |k, v| TIMEZONE_KEYS.include?(k) }]
    end

    def extract_interval_options_from(args)
      hash = args.last.kind_of?(Hash) ? args.last : {}
      Hash[hash.select { |k, v| :precision == k }]
    end


  end
end
