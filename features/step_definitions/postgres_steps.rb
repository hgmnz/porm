Then /^the (\w+) table should exist with the following columns:$/ do |table_name, columns|
  table_query_result = Porm.connection.exec(<<-SQL)
    SELECT c.oid
    FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname ~ '^(#{table_name})$'
      AND pg_catalog.pg_table_is_visible(c.oid)
  SQL
  unless table_query_result.ntuples == 1
    raise "Expected table #{table_name} to exist"
  end

  column_query_results = Porm.connection.exec(<<-SQL)
    SELECT a.attname as column_name,
      pg_catalog.format_type(a.atttypid, a.atttypmod) data_type,
      (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
       FROM pg_catalog.pg_attrdef d
       WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) as modifiers,
      a.attnotnull as not_null
    FROM pg_catalog.pg_attribute a
    WHERE a.attrelid = '#{table_query_result[0]["oid"]}' AND a.attnum > 0 AND NOT a.attisdropped
  SQL

  columns.hashes.each do |expected_column|
    column_query_results.detect do |column|
      column["column_name"] == expected_column["name"] &&
        column["data_type"] == expected_column["type"] &&
        (expected_column["modifiers"].blank? || column["modifiers"] == expected_column["modifiers"])
    end.should_not be_nil, "Expected #{expected_column.inspect} to exist"
  end
end

Then /^the following (.*) record exists:$/ do |class_name, attributes|
  result = Porm.connection.exec("select * from #{class_name.constantize.table_name}")
  attributes.hashes.each do |attribute|
    result.detect { |row| row[attribute["name"]] == attribute["value"] }.should_not be_nil, "Expected #{attribute["name"]} to be #{attribute["value"]}"
  end
end

Given /^the table "([^"]*)" exists$/ do |table_name|
  Porm.execute("create table #{table_name} ()")
end

Then /^there should be (\d+) (\w+)s?$/ do |count, table_name|
  result = Porm.select("select count(*) from #{table_name.pluralize}")
  result[0]["count"].should == count
end
