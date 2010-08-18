When /^I create a (\w+) with the following attributes:$/ do |class_name, attributes|
  args = attributes.hashes.map do |attribute|
    [attribute[:name], attribute[:value]]
  end.flatten
  class_name.constantize.send(:create, Hash[*args])
end

Given /^the following (\w+) exists:$/ do |class_name, table|
  class_name.constantize.send(:create, Hash[*table.hashes.map.flatten])
end
