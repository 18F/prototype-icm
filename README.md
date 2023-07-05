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

4. Import the data

```sh
docker exec -it oracledb impdp system/password@XEPDB1 directory=db_data dumpfile={{ filename of export file }}
```


### Run Tests

1. Run `rails test` to run unit tests
1. Run `rake cucumber` to run acceptance tests for data/reports


### Contributing

1. Start a branch `git co -b <simple-description-of-branch>`
1. Commit to the branch. Make sure your code is reasonably well-tested.
1. When you're ready, push to the branch and create a pull request


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

