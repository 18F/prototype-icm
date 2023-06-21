DOJ_FOUNDING = 1870
CURRENT_YEAR = Date.today.year

Given('report {string}') do |report_name|
  store :report, report_name
end

Given('{} is {int}') do |attribute, value|
  store attribute.to_sym, value
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

Then('expect column {int} and row {int} to be {int}') do |col, row, expected|
  report = Report.find(retrieve :report)
  actual = report.with(retrieve_all).get(col: col, row: row)
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
