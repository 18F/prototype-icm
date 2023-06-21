require "test_helper"

class ReportTest < ActiveSupport::TestCase

  def setup
    @report = Report.new(
      name: "Caseload report 1",
      query: "SELECT 101 AS count, 2.01 AS avg_data"
    )
  end

  test "gets a value" do
    assert_equal 101, @report.get(col: 1, row: 1)
  end

  test "gets values from a row" do
    assert_equal [101, 2.01], @report.get(row: 1)
  end

  test "gets values from a column" do
    assert_equal [2.01], @report.get(col: 2)
  end
end

