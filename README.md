# Integrated Case Management prototype

This is a de-risking prototype supporting the implementation of a new case management system for the Department of Justice's Civil Rights Division (DOJ CRT).

**Objective**: Learn as much as we can about CRT's reporting needs and the constraints a future data model must support.

**Method**:
- Start with CRT's current data model and sample data.
- Use a variant of the red-green-refactor loop, but for reports and data, to iterate on the data model:
  - Write acceptance tests that ensure that CRT's current reports are returning the correct data.
  - Write acceptance tests for yet-to-be implemented reports, including reports that we know the data model cannot support.
  - Alter the data model (through Rails migration steps) and report queries to support the new reports while maintaining support for the existing reports.

We are specifically not using 18F's Rails template because there are no plans to deploy this code. This prototype is entirely for the purposes of gathering information, informing decisions, de-risking, and resolving ambiguity.

### Initial setup

1. Clone this repository
1. Run `bundle install` to install dependencies
1. Make sure `db/schema.rb` hasn't been overridden (this is a known bug from running `db:migrate`)
1. Run `rails db:schema:load` to set up the initial database
1. If there are migrations because we've started to iterate on the data model, run `rails db:migrate`. Because we're iterating on the data model itself, we do not commit updated versions of the schema (post-migration) to the repository. Remember to check for schema file override after running migrations.
1. See import data instructions below before running tests

### Running Tests
1. Run `rails test` to run unit tests
1. Run `rake cucumber` to run acceptance tests for data/reports

### Contributing

1. Start a branch `git co -b <simple-description-of-branch>`
1. Commit to the branch. Make sure your code is reasonably well-tested.
1. When you're ready, push to the branch and create a pull request

### Import data

Data is private to members of 18F and CRT, and is not shared in this repository.

To import data:

1. Drop a copy of a data table csv into `db/data` (ask a team member for the current sample file)
1. Run `rake import`.
1. In a different window, open up a database console. The easist way to do this is to run `rails db`. If you're importing data to the test database, prepend the command with `RAILS_ENV=test`.
1. Copy the commands generated from `rake import`, table by table, into the database console. This will copy in the data, populating the database.


### Add reports

To add a report:

1. In `app/queries`, create a new SQL file.
1. Save the file, naming it with a "parameterized" report name - lowercase text, spaces replaced by dashes. For example, a report titled "Caseload report 1" should be saved as `caseload-report-1.sql`.
1. Paste in the SQL code that produces the desired report. Reports must only produce a single table of output. If you have multiple tables in a report, save specify the table in the filename after the report name, like `caseload-report-1-table-1.sql`.
1. In the SQL file, replace variable declarations with their Postgres equivalents, and replace the values themselves (the literals) with Mustache tags. Use simple variable names. These variables will be populated with values in the Cucumber tests. As an example, replace:

```sql
var p_startyear smallint
exec :p_startyear := 2012;

var p_startquarter smallint
exec :p_startquarter := 4;

WITH charged_hours AS (

    SELECT # ...
```

with

```sql
DECLARE p_startyear smallint;
p_startyear := {{ year }};

DECLARE p_startquarter smallint;
:p_startquarter := {{ quarter }};

WITH charged_hours AS (

    SELECT # ...
```
