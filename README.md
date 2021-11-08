# cas-postgres-style-tests
A collection of automated tests to ensure good sql coding practices and consistent formatting within a Postgres database.

## Pre-Requisites
These tests use [pgTap](https://pgtap.org/documentation.html) to run. The installation instructions & troubleshooting can be found on the pgTap [github](https://github.com/theory/pgtap/) page.

You may find it helpful to create a make target to handle the installation of pgTap for re-use in CI environments.\
(Note: a PostgreSQL server instance must be running in order to install pgTap).

Example:

```console
install_pgtap:
  ## install pgTAP extension into postgres
	@git clone https://github.com/theory/pgtap.git && \
		cd pgtap && \
		git checkout v1.1.0;
	@$(MAKE) -C pgtap
	@$(MAKE) -C pgtap install
	@$(MAKE) -C pgtap installcheck
	@rm -rf pgtap
```

## Usage
Add these tests to a place that makes sense within your project's structure.

To run all the tests within your style test directory run this command in your terminal:
```console
pg_prove -d <database name> <path/to/style/tests/>*_test.sql --set schemas_to_test=<comma separated list of schemas to test>
```

To run a single test file replace the * with the test file name:
```console
pg_prove -d <database name> <path/to/style/tests/>table_test.sql --set schemas_to_test=<comma separated list of schemas to test>
```

pg_prove has some other helpful command line options like -v (verbose). Those options can be listed by running:
```console
pg_prove --help
```

Like `install_pgtap` above, you may find it helpful to create a make target to run all your style tests.

Example:
```console
prove_style:
	# Run style test suite on all objects in schemas_to_test using pg_prove
	pg_prove --failures -d $(TEST_DB) test/style/*_test.sql --set schemas_to_test=schema1,schema2
```

## What the tests check for
The automated tests below were derived from guidelines provided for database design within the Natural Resources Ministries.

### Schema tests
- listed schemas exist
- schemas have a description
- schemas do not use reserved keywords as identifiers

### Table tests (includes Views)
- tables have a description
- table names are lower-case and separated by underscores
- tables do not use reserved keywords as identifiers

### Materialized View tests
- materialized views have a description
- materialized views are lower-case and separated by underscores
- materialized views do not use reserved keywords as identifiers
- materialized views must have a primary key

### Column tests
- columns have a description
- char columns have a defined maximum
- columns have a defined type and are not of type [text, blob, clob, xml_type]
- column names are lower-case and separated by underscores
- columns do not use reserved keywords as identifiers
