Feature: Sample reports
  Scenario: Simple sample report
    Given report "sample"
    Then expect column 1 and row 1 to be 101

  Scenario: Report with dynamic fields
    Given report "dynamic"
    And count is 99
    Then expect column 1 and row 1 to be 99

  Scenario: Report with dynamic fields
    Given report "dynamic"
    And count is 100
    Then expect column 1 and row 1 to be 100
