Then /^I should be able to find a (\w+) with login "([^"]*)"$/ do |class_name, login|
  class_name.constantize.send(:where, {:login => login}).first.should_not be_nil, "Expected to find user with login #{login}"
end

Then /^I should not be able to find a (\w+) with login "([^"]*)"$/ do |class_name, login|
  class_name.constantize.send(:where, {:login => login}).first.should be_nil, "Expected not to find user with login #{login}"
end
