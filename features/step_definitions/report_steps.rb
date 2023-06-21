DOJ_FOUNDING = 1870
CURRENT_YEAR = Date.today.year

Given('report {string}') do |report_name|
  store :report, report_name
end

Given('{} is {int}') do |attribute, value|
  store attribute.to_sym, value
end

Given('start date is {}') do |date|
  store :start_date, Date.parse(date).iso8601
end

Given('end date is {}') do |date|
  store :end_date, Date.parse(date).iso8601
end

Given('date is Q{int} FY{int}') do |quarter, fy|
  raise ArgumentError unless [1,2,3,4].include?(quarter)
  year = fy.digits.length == 2 ? 2000 + year : year
  raise ArgumentError unless (DOJ_FOUNDING..THIS_YEAR).include?(year)
  dates = case quarter
          when 1 then [Date.new(year, 10, 1), Date.new(year, 12, 31)]
          when 2 then [Date.new(year,  1, 1), Date.new(year,  3, 31)]
          when 3 then [Date.new(year,  4, 1), Date.new(year,  6, 30)]
          when 4 then [Date.new(year,  7, 1), Date.new(year,  9, 30)]
          else
            raise "I didn't expect `Q#{quarter}`, I expected Q1 through Q4."
          end
  store :start_date, dates.first
  store :end_date, dates.last
end

When('I run the report') do
  report = Report.find(retrieve :report)
  store :results, report.with(retrieve_all)
end

Then('expect column {int} and row {int} to be {int}') do |col, row, expected|
  actual = retrieve(:results).get(col: col, row: row)
  assert_equal expected, actual
end

Then('expect column {} to have numbers {number_array}') do |col, expected|
  pending
  assert_number(column)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

Then('expect row {} to have numbers {number_array}') do |row, expected|
  pending
  assert_number(row)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

Then('expect the value to be {int}') do |expected|
  actual = retrieve(:results).get(col: 1, row: 1)
  assert_equal expected, actual
end

Then('expect a value of {int}') do |expected|
  actual = retrieve(:results).get(col: 1, row: 1)
  assert_equal expected, actual
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
  @container ||= Hash.new
end

def assert_number(*args)
  args.each do |arg|
    raise ArgumentError unless arg.is_a?(Numeric)
  end
end
