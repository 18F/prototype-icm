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

  test "stores and retrieves reports by name" do
    assert Report.find("Caseload report 1").present?
  end

  test "gets values by column name" do
    report = Report.new(name: "stubbed query", query: "shouldn't matter")
    report.stub_results(
      [
        {" " => "HCE", "A" => 10, "B" => 20},
        {" " => "DRS", "A" =>  8, "B" =>  5},
        {" " => "CRM", "A" => 25, "B" => 32},
      ]
    )
    examples = [
      { col: "A", row: "DRS", expect:  8          },
      { col: "B",             expect: [20, 5, 32] },
      {           row: "DRS", expect: [8, 5]      },
      { col:   1, row:     3, expect: "CRM"       },
    ]
    examples.each do |example|
      opts = example.reject { |k,_| k == :expect }
      actual = report.get(**opts)
      assert_equal example[:expect], actual
    end
  end
end

