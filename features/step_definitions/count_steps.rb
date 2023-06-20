require "test/unit/assertions"

# standard:disable Style/MixinUsage
extend Test::Unit::Assertions
# standard:enable Style/MixinUsage

Given('whatever') do
  @state ||= "I'm the test state!"
  puts @state
end

Then('there should be {int} {string}') do |count, model_name|
  @state += " Here's a test! "
  model_class = Kernel.const_get(model_name.classify)
  puts @state
  assert_equal count, model_class.count
end

# Given ('report {string}') do |report_name|
#   results = get(report_name).run
# end

# Then ('there should be {int} results for column {string}') do |count, col|
#   vlookup(results, 3, column Y)
# end
