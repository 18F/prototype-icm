# Integrated Case Management prototype

This is a de-risking prototype supporting the implementation of a new case management system for the Department of Justice's Civil Rights Division (DOJ CRT).

**Objective**: Learn as much as we can about CRT's reporting needs and the constraints a future data model must support.

**Outputs**:
- Discovering must-have data model constraints to support the vendor evaluation.
- A pre-run of part of the data migration.
- A data migration acceptance testing script, human-readable.
- A data migration acceptance testing script, machine-readable.

**Method**:
- Start with CRT's current data model and sample data.
- Use a variant of the red-green-refactor loop, but for reports and data, to iterate on the data model:
  - Write acceptance tests that ensure that CRT's current reports are returning the correct data.
  - Write acceptance tests for yet-to-be implemented reports, including reports that we know the data model cannot support.
  - Alter the data model (through Rails migration steps) and report queries to support the new reports while maintaining support for the existing reports.

We are specifically not using 18F's Rails template because there are no plans to deploy this code. This prototype is entirely for the purposes of gathering information, informing decisions, de-risking, and resolving ambiguity.

## Initial setup

### First steps

1. Clone this repository
1. [Follow the Oracle installation instructions](https://www.rubydoc.info/github/kubo/ruby-oci8/file/docs/install-on-osx.md)
1. Run `bundle install` to install dependencies
1. Follow the next section on setting up an Oracle database

### Set up an Oracle database

If you have a database export, you can set up an Oracle database with it. Make sure the file is in `db/data`, or change the commands to point to your preferred setup.

1. Get a copy of the database export file (ending in `.dmp`) and a copy of the oracle_setup.sql script from a teammate.

2. Start the database. Make sure you're running this command in such a way that `-v ./db/data` points to the right place, or modify the path accordingly.

```sh
docker run \
  --name oracledb \
  -p 1521:1521 \
  -e ORACLE_PWD=password \
  -v ./db/data:/db/data \
  -v /opt/oracle/oradata \
  container-registry.oracle.com/database/express:21.3.0-xe
```

3. Check if the `db/data` volume mounted properly. You should see the same files using this command as you do in the application's `db/data` folder.

```sh
docker exec -it oracledb ls /db/data
```

4. Set up the database. First log in:

```sh
docker exec -it oracledb sqlplus sys/password@XEPDB1 as sysdba
```

Then run the SQL in `db/data/oracle_setup.sql` by copying and pasting it into the database console.

5. Import the data

```sh
docker exec -it oracledb impdp system/password@XEPDB1 directory=db_data dumpfile={{ filename of export file }}
```


### Run Tests

1. Run `bin/acceptance` to run acceptance tests. By default, they run for the development environment. Prepend the command with `ENV=production` to run the acceptance tests with production expectations.
1. Run `rails test` to run unit tests


### Contributing

1. Start a branch `git co -b <simple-description-of-branch>`
1. Commit to the branch. Make sure your code is reasonably well-tested.
1. When you're ready, push to the branch and create a pull request


### Add reports

To add a report:

1. In `app/queries`, create a new SQL file.
2. Save the file, giving it a filename that describes the report. If it's a section report, start it with the section abbreviation (e.g. `ELS`).
3. Paste in the SQL code that produces the desired report. Reports must only produce a single table of output. If you have multiple tables in a report, save specify the table in the filename after the report name, like `{section code} {report name} Table 1.sql`.
4. In the SQL file, replace variable literal values with Oracle-style interpolation tags `{? var_name }`. Use simple `snake_cased` variable names. These variables will be populated with values in the acceptance tests. As an example, replace the variable values in the original SQL:

```sql
var p_startyear smallint
exec :p_startyear := 2012;

var p_startquarter smallint
exec :p_startquarter := 4;

WITH charged_hours AS (

    SELECT # ...
```

with simple variable names like

```sql
var p_startyear smallint
exec :p_startyear := {? start_year };

var p_startquarter smallint
exec :p_startquarter := {? quarter };

WITH charged_hours AS (

    SELECT # ...
```

5. Make sure the report made it in. Run `rails console` and then

```ruby
Report.all.map(&:name).grep /a snippet of the report title/
```

6. Check the results by running the report:

```ruby
Report.find({ title or ID }). # Find a report by its full name or by its position in Report.all
  with(required_var: value).  # Give it all the values it needs for evaluation. See a report's variables with Report#variables.
  results.first(10)           # To keep displayed results to a minimum
```

7. Add expectations for a report by writing acceptance tests. Replace literal expectation values with tags like `{{ section.report.expectation_name }}` and fill in the values for development and production in `features/test_values.yml`.
