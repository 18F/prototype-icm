Feature: Section reports

  Scenario: Section - Hours Worked by Specified DJ with Special DJ
    Given the report "Section - Hours Worked by Specified DJ with Special DJ"
    And section is "CRM"
    And date1 is "03/15/2020"
    And date2 is "01/06/2021"
    # And dj_number is "000-000-000"
    When I run the report
    Then expect results

  Scenario: Section - Hours Worked by Specified User
    Given the report "Section - Hours Worked by Specified User"
    And section is "CRM"
    And date1 is "03/15/2020"
    And date2 is "01/06/2021"
    And staff_id is "SHARRELL"
    When I run the report
    Then expect 3 results
    Then expect column "case_name" to contain "017"
