Feature: SPL
  Scenario: Docket Review Report by Staff
    Given the report "SPL - Docket Review Report by Staff"
    And staff_id is {{ spl.docket.staff_id }}
    When I run the report
    Then expect {{ spl.docket.count }} results
    And expect column "case_name" to contain {{ spl.docket.case_name }}

  Scenario: Hours Worked by Staff Summary
    Given the report "SPL - Hours Worked by Staff Summary"
    And date1 is "05/01/2020"
    And date2 is "05/31/2023"
    And staff_id is {{ spl.hours.staff_id }}
    When I run the report
    Then expect {{ spl.hours.count }} results
    And expect column "dj_number" to contain {{ spl.hours.dj_number.1 }}
    And expect column "dj_number" to contain {{ spl.hours.dj_number.2 }}
    And expect column "dj_number" to contain {{ spl.hours.dj_number.3 }}

  # TODO: Add an expectation that differentiates Docket Review from Staff Assignment
  Scenario: Staff Assignment Report
    Given the report "SPL - Staff Assignment Report"
    And staff_id is {{ spl.assignment.staff_id }}
    When I run the report
    Then expect {{ spl.assignment.count }} results
    And expect column "case_name" to contain {{ spl.assignment.case_name }}
