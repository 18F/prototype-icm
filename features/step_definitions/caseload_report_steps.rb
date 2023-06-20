DOJ_FOUNDING = 1870
CURRENT_YEAR = Date.today.year

Given('report {string}') do |report_name|
  store :report, report_name
end

Given('date is Q{int} FY{int}') do |quarter, fy|
  raise ArgumentError unless [1,2,3,4].include?(quarter)

  year = fy.digits.length == 2 ? 2000 + year : year
  raise ArgumentError unless (DOJ_FOUNDING..THIS_YEAR).include?(year)
  dates = case quarter
          when 1 then [Date.new(year,  1, 1), Date.new(year,  3, 31)]
          when 2 then [Date.new(year,  4, 1), Date.new(year,  6, 30)]
          when 3 then [Date.new(year,  7, 1), Date.new(year,  9, 30)]
          when 4 then [Date.new(year, 10, 1), Date.new(year, 12, 31)]
          else
            raise "Well this was unexpected"
          end
  store :start_date, dates.first
  store :end_date, dates.last
end

Then('expect column {} and row {} to be {}') do |column, row, expected|
  pending
  guard_is_string_or_number(column, row, expected)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

Then('expect column {} to have numbers {number_array}') do |column, expected|
  pending
  guard_is_string_or_number(column)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

Then('expect row {} to have numbers {number_array}') do |row, expected|
  pending
  guard_is_string_or_number(row)
  actual = raise NotImplementedError
  assert_equal expected, actual
end

def store(key, value)
  registry.register(key, value)
end

def registry
  @container ||= Dry::Container.new
end

def guard_is_string_or_number(*args)
  args.each do |arg|
    raise ArgumentError unless arg.is_a?(String) or arg.is_a?(Integer)
  end
end
