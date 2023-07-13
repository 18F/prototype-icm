Feature: ELS
  Scenario: New Open Matters and Cases by District
    Given the report "ELS - New Open Matters and Cases by District"
    And the date is May 1 2023
    When I run the report
    Then expect 195 results
    Then expect column 3 to contain "LOS ANGELES POLICE DEPARTMENT"

  Scenario: Case and Matter Assignment by attorney
    Given the report "ELS - Case and Matter Assignment by attorney"
    And the staff_id is {{ els.assignment.staff_id }}
    When I run the report
    Then expect {{ els.assignment.count }} results
    And expect column 5 to contain {{ els.assignment.dj_number }}
