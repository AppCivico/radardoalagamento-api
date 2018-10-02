use utf8;
package Tupa::Schema::Result::RasterOverview;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::RasterOverview

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

=head1 TABLE: C<raster_overviews>

=cut

__PACKAGE__->table("raster_overviews");
__PACKAGE__->result_source_instance->view_definition(" SELECT current_database() AS o_table_catalog,\n    n.nspname AS o_table_schema,\n    c.relname AS o_table_name,\n    a.attname AS o_raster_column,\n    current_database() AS r_table_catalog,\n    (split_part(split_part(s.consrc, '''::name'::text, 1), ''''::text, 2))::name AS r_table_schema,\n    (split_part(split_part(s.consrc, '''::name'::text, 2), ''''::text, 2))::name AS r_table_name,\n    (split_part(split_part(s.consrc, '''::name'::text, 3), ''''::text, 2))::name AS r_raster_column,\n    (btrim(split_part(s.consrc, ','::text, 2)))::integer AS overview_factor\n   FROM pg_class c,\n    pg_attribute a,\n    pg_type t,\n    pg_namespace n,\n    pg_constraint s\n  WHERE ((t.typname = 'raster'::name) AND (a.attisdropped = false) AND (a.atttypid = t.oid) AND (a.attrelid = c.oid) AND (c.relnamespace = n.oid) AND ((c.relkind)::text = ANY ((ARRAY['r'::character(1), 'v'::character(1), 'm'::character(1), 'f'::character(1)])::text[])) AND (s.connamespace = n.oid) AND (s.conrelid = c.oid) AND (s.consrc ~~ '%_overview_constraint(%'::text) AND (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text))");

=head1 ACCESSORS

=head2 o_table_catalog

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 o_table_schema

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 o_table_name

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 o_raster_column

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 r_table_catalog

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 r_table_schema

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 r_table_name

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 r_raster_column

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 overview_factor

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "o_table_catalog",
  { data_type => "name", is_nullable => 1, size => 64 },
  "o_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "o_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "o_raster_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_table_catalog",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_raster_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "overview_factor",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-21 22:01:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OVzLwnj7jQehTU5h6Av3vw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
