Then /^the (\w+) table should exist with the following columns:$/ do |table_name, columns|
  table_query_result = PG_CONN.exec(<<-SQL)
    SELECT c.oid
    FROM pg_catalog.pg_class c
         LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname ~ '^(#{table_name})$'
      AND pg_catalog.pg_table_is_visible(c.oid)
  SQL
  unless table_query_result.ntuples == 1
    raise "Expected table #{table_name} to exist"
  end

  column_query_results = PG_CONN.exec(<<-SQL)
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
    column_query_results.detect { |column| column["column_name"] == expected_column["name"] &&
      column["data_type"] == expected_column["type"] }.should_not be_nil, "Expected #{expected_column.inspect} to exist"
  end
end

Then /^the following (.*) record exists:$/ do |class_name, attributes|
  result = PG_CONN.exec("select * from #{class_name.constantize.table_name}")
  attributes.hashes.each do |attribute|
    result.detect { |row| row[attribute["name"]] == attribute["value"] }.should_not be_nil, "Expected #{attribute["name"]} to be #{attribute["value"]}"
  end
end

Given /^the table "([^"]*)" exists$/ do |table_name|
  PG_CONN.exec("create table #{table_name} ()")
end
