DOJ_FOUNDING = 1870
CURRENT_YEAR = Date.today.year
TYPES = %w(reference string int)

Given("report {string}") do |report_name|
  store :report, report_name
end

Given("{article} {string} report") do |_, report_name|
  store :report, report_name
end

Given("{article} report {string}") do |_, report_name|
  store :report, report_name
end

Given("start date is {}") do |date|
  store :start_date, Date.parse(date).iso8601
end

Given("end date is {}") do |date|
  store :end_date, Date.parse(date).iso8601
end

Given("{article} date is {}") do |_, date|
  store :date, Date.parse(date).iso8601
end

TYPES.each do |type_name|
  Given("{} is {#{type_name}}") do |attribute, value|
    store attribute.to_sym, value
  end

  # Given("{article} {} is {#{type_name}}") do |_, attribute, value|
  #   store attribute.to_sym, value
  # end
end

# Matches:
#   date is Q4 FY22
#   date is Q1 FY2023
Given("date is Q{int} FY{int}") do |quarter, fy|
  raise ArgumentError unless [1, 2, 3, 4].include?(quarter)
  year = (fy.digits.length == 2) ? 2000 + year : year
  raise ArgumentError unless (DOJ_FOUNDING..THIS_YEAR).cover?(year)
  dates = case quarter
  when 1 then [Date.new(year, 10, 1), Date.new(year, 12, 31)]
  when 2 then [Date.new(year, 1, 1), Date.new(year, 3, 31)]
  when 3 then [Date.new(year, 4, 1), Date.new(year, 6, 30)]
  when 4 then [Date.new(year, 7, 1), Date.new(year, 9, 30)]
  else
    raise "I didn't expect `Q#{quarter}`, I expected Q1 through Q4."
  end
  store :start_date, dates.first
  store :end_date, dates.last
end

When("I run the report") do
  report = Report.find(retrieve(:report))
  store :results, report.with(retrieve_all)
  # Run this to get query runtime errors to happen here.
  report.results
rescue QueryEvaluationError => e
  fail_query_evaluation_error(e)
end

TYPES.each do |type_name|
  Then("expect column {int} to contain {#{type_name}}") do |col, expected|
    assert col_contains(col, /#{expected}/i)
  end

  Then("expect column {string} to contain {#{type_name}}") do |col, expected|
    assert col_contains(col, /#{expected}/i)
  end

  Then("expect column {int} to match {#{type_name}} exactly") do |col, expected|
    assert col_contains(col, /^#{expected}$/)
  end

  Then("expect column {string} to match {#{type_name}} exactly") do |col, expected|
    assert col_contains(col, /^#{expected}$/)
  end

  Then("expect column {string} to be {#{type_name}}") do |col, expected|
    actual = retrieve(:results).get(col: col, row: 1)
    assert_equal expected, actual
  end
end

def col_contains(col, matcher)
  retrieve(:results).get(col: col).any? { |value|
    value.match?(matcher)
  }
rescue => e
  puts "report: #{retrieve(:results)}"
  puts "res.col: #{retrieve(:results).get(col: col)}"
  raise e
end

Then("expect column {int} and row {int} to be {reference}") do |col, row, expected|
  actual = retrieve(:results).get(col: col, row: row)
  assert_equal expected, actual
end

Then("expect column {} to have numbers {number_array}") do |col, expected|
  pending
  assert_number(col)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

Then("expect row {} to have numbers {number_array}") do |row, expected|
  pending
  assert_number(row)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

# Matches these and others:
#   Then expect the value to be {int}
#   Then expect the count will be {int}
#   Then expect a sum of {int}
#   Then expect the total is {int}
Then("expect {article} {value_word} {lead_in} {reference}") do |_, _, _, expected|
  # TODO: Raise if there's more than 1 column and 1 row
  actual = retrieve(:results).get(col: 1, row: 1)
  assert_equal expected, actual
end

TYPES.each do |type_name|
  Then("expect {#{type_name}} results") do |expected|
    actual = retrieve(:results).get.count
    assert_equal expected, actual
  end
end

Then("expect results") do
  warn <<~WARNING
    You have an `expect values` clause which does not actually run a test.
    Remember to replace it later.
  WARNING
  results = retrieve(:results).get
  if results.count == 0
    raise "There are no results!"
  elsif results.count > 10
    warn "There are #{results.count} results, here are the first 10."
    format_results results.first(10).map { |res| res.to_s.truncate(100) }
  else
    format_results(results)
  end
end

def format_results(results)
  puts "Results"
  puts "-------"
  puts results
  puts "\n-------"
end

def store(key, value)
  registry.merge!(key => value)
end

def retrieve(key)
  registry.fetch(key)
end

def retrieve_all
  registry
end

def registry
  @container ||= {}
end

def assert_number(*args)
  args.each do |arg|
    raise ArgumentError unless arg.is_a?(Numeric)
  end
end


def fail_query_evaluation_error(error_object)
  nil_vars = error_object.variables.select { |k, v| k if v.nil? }
  examples = nil_vars.map.with_index do |pair, i|
    k, _ = pair
    "And #{k} is {YOUR VALUE HERE}"
  end.join("\n    ")
  fail <<~MESSAGE

    The report "#{error_object.report_name}" doesn't have all the variables
    it needs in order to run.

    Please define values for #{nil_vars.keys.map {|v| "`#{v}`"}.join(", ")} by adding them to the test,
    in the "Given" section after the report, like:

        #{examples}

  MESSAGE
end
