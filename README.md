# Integrated case management prototype

This is a de-risking prototype supporting the implementation of a new case management system for the Department of Justice's Civil Rights Division (DOJ CRT).

**Objective**: Learn as much as we can about CRT's reporting needs and the constraints a future data model must support.

**Method**:
- Start with CRT's current data model and sample data.
- Use a variant of the red-green-refactor loop, but for reports and data, to iterate on the data model:
  - Write acceptance tests that ensure that CRT's current reports are returning the correct data.
  - Write acceptance tests for yet-to-be implemented reports, including reports that we know the data model cannot support.
  - Alter the data model (through Rails migration steps) and report queries to support the new reports while maintaining support for the existing reports.

We are specifically not using 18F's Rails template because there are no plans to deploy this code. This prototype is entirely for the purposes of gathering information, informing decisions, de-risking, and resolving ambiguity.

