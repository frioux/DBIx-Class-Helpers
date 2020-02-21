When contributing, please take care to have sane history.  For simple features
it should be a single commit.  If you need complex history, add functionality
per commit in the order such that everything passes tests for each commit.

When submitting a PR, in the commit include a line in the Changes underneath
{{$NEXT}} of the form:

         - Fix the foobar whatsit (Thanks FullName!)

If there is an existing issue, include it in the line:

         - Create special cat mode (Thanks FullName!) (Closes GH#123)

If, inexplicably, there is an existing issue in RT, prefix the issue number
with RT:

         - Create standard dog mode (Thanks FullName!) (Closes RT#100123)

## DDL

To Generate ddl.sql which will allow you to run prove -l use the following command:
perl -Ilib -It/lib -MTestSchema -E'TestSchema->generate_ddl; my $t = TestSchema->connect; $t->deploy'

Eventually that will be migrated into it's own Dzil plugin, but for now that should work

## Testing

To run tests against all major supported databases use:

```
$ maint/dockerprove -lr t
```

You can set DBIITEST_STARTUP to 10 or 15 to wait longer for the databases to be
ready to test against.  Default is 5s.

## Writing Tests

By default, tests will only be run against SQLite. To write tests
that will run on other DBs, use Test::Roo, and compose in the role
A::Role::TestConnect. This will lazily connect (and deploy) the
schema once the schema method is called. To run tests only if
connected, check the connected method.

For the simplest example of this, take a look at t/ResultSet/Explain.t.

## Releasing

```
$ maint/release
```
