Feature: Sample matter reports
  Scenario: Matter count report
    Given the "matter count" report
    When I run the report
    Then expect the value will be 147108

  # Scenario: Matter count report by date
  #   Given report "matter count by date"
  #   And start date is Nov 1, 2018
  #   And end date is 06/01/2019
  #   When I run the report
  #   Then expect the count to be 8

  # Scenario: Matter count report by dates
  #   Given report "matter count by date"
  #   And start date is <start>
  #   And end date is <end>
  #   When I run the report
  #   Then expect a count of <expected>

  #   Examples:
  #     | start      | end              | expected |
  #     | 1/1/01     | 2/02/2002        | 196      |
  #     | Jan 1 2001 | February 2, 2002 | 196      |
  #     | 1/1/01     | February 2, 2003 | 343      |
