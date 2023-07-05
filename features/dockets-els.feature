Feature: ELS Docket Reports
  Scenario:
    Given the report "ELS - New Open Matters and Cases by District"
    And the date is Oct 1 2022
    When I run the report
    Then expect 194 results
