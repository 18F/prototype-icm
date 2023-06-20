Feature: Caseload report
  Scenario: Caseload report 1 - No. of cases filed by section
    Given report "Caseload report 1"
    And date is Q1 FY2022
    Then expect column "FY 2021" and row "Criminal" to be 134
    And expect column "FY 2022" and row "Voting" to be 4

  Scenario: Caseload report 2 - No. of settlements, consent decrees, or judgments
    Given report "Caseload report 2"
    And date is Q1 FY2022
    Then expect column 2 to have numbers [114, 19, 13, 16, 1, 34, 35, 1, 4, 286]
    Then expect row "Immigration & Employee Rights" to have numbers [54, 13, 55, 14]
    And expect column "FY 2022" and row "Voting" to be 4

