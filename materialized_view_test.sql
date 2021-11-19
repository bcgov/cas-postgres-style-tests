set client_min_messages to warning;
create extension if not exists pgtap;
reset client_min_messages;

begin;

set search_path to :schemas_to_test,public;

select * from no_plan();

/** Check materialized view compliance **/

-- GUIDELINE: All materialized views should have descriptions
-- Check all materialized views for an existing description (regex '.+')
with mvnames as (select matviewname from pg_matviews where schemaname = any (string_to_array(:'schemas_to_test', ',')))
select matches(
               obj_description(mv::regclass, 'pg_class'),
               '.+',
               format('Materialized view has a description. Violation: %I', mv)
           )
from mvnames f(mv);

-- GUIDELINE: Names are lower-case with underscores_as_word_separators
-- Check that all materialized view names match format: lowercase, starts with a letter charater, separated by underscores
with mvnames as (select matviewname from pg_matviews where schemaname = any (string_to_array(:'schemas_to_test', ',')))
select matches(
               mv,
               '^[a-z]+[a-z0-9]*(?:_[a-z0-9]+)*',
               format('Materialized view names are lower-case and separated by underscores. Violation: %I', mv)
           )
from mvnames f(mv);

-- GUIDELINE: Materialized view names do not use reserved keywords as identifiers
select is_empty(
  $$
    select schemaname, matviewname from pg_matviews
    where schemaname = any (string_to_array((SELECT setting FROM pg_settings WHERE name = 'search_path'), ', '))
    and matviewname in (select word from pg_get_keywords() where catcode !='U')
    order by schemaname, matviewname
  $$,
  'Materialized views do not use reserved keywords as identifiers. Violation format: {schema, matview}'
);

-- GUIDELINE: All materialized views must have a primary key
-- Get all materialized views in schema that do not have a unique index
prepare null_pkey as
  select distinct matviewname from pg_matviews
  left join pg_indexes
  on matviewname = tablename
  where matviewname not in (
  select pi.tablename
  from pg_catalog.pg_namespace n
  join pg_catalog.pg_class c on c.relnamespace = n.oid
  join pg_catalog.pg_index i on i.indexrelid = c.oid
  join pg_indexes pi on relname=indexname
  where n.nspname = any (string_to_array(:'schemas_to_test', ','))
  and i.indisunique=true)
  and pg_matviews.schemaname = any (string_to_array(:'schemas_to_test', ','));
-- Test that the above query returns nothing, else throw an error
select is_empty('null_pkey', 'All materialized views must have a primary key');

select * from finish();

rollback;
