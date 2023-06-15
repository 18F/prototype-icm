require "test/unit/assertions"

# standard:disable Style/MixinUsage
extend Test::Unit::Assertions
# standard:enable Style/MixinUsage

Given("I am on the home page") do
  # NO OP
end

Then("I should see {string}") do |expected|
  assert_equal expected, "Welcome to my site."
end
