Given /^I save the following as (.*):$/ do |filename, file_contents|
  path = nil
  Tempfile.open(filename) do |f|
    f.puts file_contents
    path = f.path
  end
  load path
end

Then /^I should be able to save the following as (.*):$/ do |filename, file_contents|
  Given "I save the following as #{filename}:", file_contents
end
