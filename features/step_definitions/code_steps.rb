Given /^@result is nil$/ do
  @result = nil
end

Then /^@result should be "([^"]*)"$/ do |value|
  @result.should == value
end

When /^I run the following code:$/ do |code|
  eval(code)
end

Then /^the following should fail:$/ do |code|
  result = nil
  eval(code).on_failure(lambda { result = 'foo' })
  result.should == 'foo'
end

Then /^the following should pass:$/ do |code|
  result = nil
  eval(code).on_success(lambda { result = 'foo' })
  result.should == 'foo'
end
