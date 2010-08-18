Given /^@result is nil$/ do
  @result = nil
end

Then /^@result should be "([^"]*)"$/ do |value|
  @result.should == value
end

When /^I run the following code:$/ do |code|
  eval(code)
end

