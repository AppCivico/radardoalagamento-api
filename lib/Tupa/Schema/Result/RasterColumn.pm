use utf8;
package Tupa::Schema::Result::RasterColumn;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::RasterColumn

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

=head1 TABLE: C<raster_columns>

=cut

__PACKAGE__->table("raster_columns");
__PACKAGE__->result_source_instance->view_definition(" SELECT current_database() AS r_table_catalog,\n    n.nspname AS r_table_schema,\n    c.relname AS r_table_name,\n    a.attname AS r_raster_column,\n    COALESCE(_raster_constraint_info_srid(n.nspname, c.relname, a.attname), ( SELECT st_srid('010100000000000000000000000000000000000000'::geometry) AS st_srid)) AS srid,\n    _raster_constraint_info_scale(n.nspname, c.relname, a.attname, 'x'::bpchar) AS scale_x,\n    _raster_constraint_info_scale(n.nspname, c.relname, a.attname, 'y'::bpchar) AS scale_y,\n    _raster_constraint_info_blocksize(n.nspname, c.relname, a.attname, 'width'::text) AS blocksize_x,\n    _raster_constraint_info_blocksize(n.nspname, c.relname, a.attname, 'height'::text) AS blocksize_y,\n    COALESCE(_raster_constraint_info_alignment(n.nspname, c.relname, a.attname), false) AS same_alignment,\n    COALESCE(_raster_constraint_info_regular_blocking(n.nspname, c.relname, a.attname), false) AS regular_blocking,\n    _raster_constraint_info_num_bands(n.nspname, c.relname, a.attname) AS num_bands,\n    _raster_constraint_info_pixel_types(n.nspname, c.relname, a.attname) AS pixel_types,\n    _raster_constraint_info_nodata_values(n.nspname, c.relname, a.attname) AS nodata_values,\n    _raster_constraint_info_out_db(n.nspname, c.relname, a.attname) AS out_db,\n    _raster_constraint_info_extent(n.nspname, c.relname, a.attname) AS extent,\n    COALESCE(_raster_constraint_info_index(n.nspname, c.relname, a.attname), false) AS spatial_index\n   FROM pg_class c,\n    pg_attribute a,\n    pg_type t,\n    pg_namespace n\n  WHERE ((t.typname = 'raster'::name) AND (a.attisdropped = false) AND (a.atttypid = t.oid) AND (a.attrelid = c.oid) AND (c.relnamespace = n.oid) AND (c.relkind = ANY (ARRAY['r'::\"char\", 'v'::\"char\", 'm'::\"char\", 'f'::\"char\", 'p'::\"char\"])) AND (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text))");

=head1 ACCESSORS

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

=head2 srid

  data_type: 'integer'
  is_nullable: 1

=head2 scale_x

  data_type: 'double precision'
  is_nullable: 1

=head2 scale_y

  data_type: 'double precision'
  is_nullable: 1

=head2 blocksize_x

  data_type: 'integer'
  is_nullable: 1

=head2 blocksize_y

  data_type: 'integer'
  is_nullable: 1

=head2 same_alignment

  data_type: 'boolean'
  is_nullable: 1

=head2 regular_blocking

  data_type: 'boolean'
  is_nullable: 1

=head2 num_bands

  data_type: 'integer'
  is_nullable: 1

=head2 pixel_types

  data_type: 'text[]'
  is_nullable: 1

=head2 nodata_values

  data_type: 'double precision[]'
  is_nullable: 1

=head2 out_db

  data_type: 'boolean[]'
  is_nullable: 1

=head2 extent

  data_type: 'geometry'
  is_nullable: 1

=head2 spatial_index

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "r_table_catalog",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "r_raster_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "srid",
  { data_type => "integer", is_nullable => 1 },
  "scale_x",
  { data_type => "double precision", is_nullable => 1 },
  "scale_y",
  { data_type => "double precision", is_nullable => 1 },
  "blocksize_x",
  { data_type => "integer", is_nullable => 1 },
  "blocksize_y",
  { data_type => "integer", is_nullable => 1 },
  "same_alignment",
  { data_type => "boolean", is_nullable => 1 },
  "regular_blocking",
  { data_type => "boolean", is_nullable => 1 },
  "num_bands",
  { data_type => "integer", is_nullable => 1 },
  "pixel_types",
  { data_type => "text[]", is_nullable => 1 },
  "nodata_values",
  { data_type => "double precision[]", is_nullable => 1 },
  "out_db",
  { data_type => "boolean[]", is_nullable => 1 },
  "extent",
  { data_type => "geometry", is_nullable => 1 },
  "spatial_index",
  { data_type => "boolean", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-21 22:01:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zZw+V0oagSCCqZbi+9t9SQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
