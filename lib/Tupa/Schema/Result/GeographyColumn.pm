use utf8;
package Tupa::Schema::Result::GeographyColumn;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::GeographyColumn

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<geography_columns>

=cut

__PACKAGE__->table("geography_columns");
__PACKAGE__->result_source_instance->view_definition(" SELECT current_database() AS f_table_catalog,\n    n.nspname AS f_table_schema,\n    c.relname AS f_table_name,\n    a.attname AS f_geography_column,\n    postgis_typmod_dims(a.atttypmod) AS coord_dimension,\n    postgis_typmod_srid(a.atttypmod) AS srid,\n    postgis_typmod_type(a.atttypmod) AS type\n   FROM pg_class c,\n    pg_attribute a,\n    pg_type t,\n    pg_namespace n\n  WHERE ((t.typname = 'geography'::name) AND (a.attisdropped = false) AND (a.atttypid = t.oid) AND (a.attrelid = c.oid) AND (c.relnamespace = n.oid) AND (c.relkind = ANY (ARRAY['r'::\"char\", 'v'::\"char\", 'm'::\"char\", 'f'::\"char\", 'p'::\"char\"])) AND (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text))");

=head1 ACCESSORS

=head2 f_table_catalog

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_table_schema

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_table_name

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_geography_column

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 coord_dimension

  data_type: 'integer'
  is_nullable: 1

=head2 srid

  data_type: 'integer'
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_geography_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "coord_dimension",
  { data_type => "integer", is_nullable => 1 },
  "srid",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-21 22:01:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CCwvg2SporHZDBXXwKJAmw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
