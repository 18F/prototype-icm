Feature: Median time per case

Scenario:
  Given the "Median case time by case name" report
  And case_name_search is "EPA"
  When I run the report
  # Then expect results
  Then expect 1 results
  And expect column "Average days" to be 1449
  And expect column "Median days" to be 879
  And expect column "Average hours" to be 887
  And expect column "Median hours" to be 268

  And expect column "Max hours" to be 22470
  And expect column "Min hours" to be 81
  And expect column "Max days" to be 10716
  And expect column "Min days" to be 49
