Feature: ELS
  Scenario: New Open Matters and Cases by District
    Given the report "ELS - New Open Matters and Cases by District"
    And the date is May 1 2023
    When I run the report
    Then expect 158 results
    And expect column 3 to contain "oracle"


  Scenario: Case and Matter Assignment by attorney
  Given the report "ELS - Case and Matter Assignment by attorney"
  And the staff_id is "KWOODARD"
  When I run the report
  Then expect 23 results
  And expect column 2 to contain "170-87-22"
