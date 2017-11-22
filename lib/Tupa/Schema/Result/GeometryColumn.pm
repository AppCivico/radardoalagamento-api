use utf8;
package Tupa::Schema::Result::GeometryColumn;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::GeometryColumn

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

=head1 TABLE: C<geometry_columns>

=cut

__PACKAGE__->table("geometry_columns");
__PACKAGE__->result_source_instance->view_definition(" SELECT (current_database())::character varying(256) AS f_table_catalog,\n    n.nspname AS f_table_schema,\n    c.relname AS f_table_name,\n    a.attname AS f_geometry_column,\n    COALESCE(postgis_typmod_dims(a.atttypmod), sn.ndims, 2) AS coord_dimension,\n    COALESCE(NULLIF(postgis_typmod_srid(a.atttypmod), 0), sr.srid, 0) AS srid,\n    (replace(replace(COALESCE(NULLIF(upper(postgis_typmod_type(a.atttypmod)), 'GEOMETRY'::text), st.type, 'GEOMETRY'::text), 'ZM'::text, ''::text), 'Z'::text, ''::text))::character varying(30) AS type\n   FROM ((((((pg_class c\n     JOIN pg_attribute a ON (((a.attrelid = c.oid) AND (NOT a.attisdropped))))\n     JOIN pg_namespace n ON ((c.relnamespace = n.oid)))\n     JOIN pg_type t ON ((a.atttypid = t.oid)))\n     LEFT JOIN ( SELECT s.connamespace,\n            s.conrelid,\n            s.conkey,\n            replace(split_part(s.consrc, ''''::text, 2), ')'::text, ''::text) AS type\n           FROM pg_constraint s\n          WHERE (s.consrc ~~* '%geometrytype(% = %'::text)) st ON (((st.connamespace = n.oid) AND (st.conrelid = c.oid) AND (a.attnum = ANY (st.conkey)))))\n     LEFT JOIN ( SELECT s.connamespace,\n            s.conrelid,\n            s.conkey,\n            (replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text))::integer AS ndims\n           FROM pg_constraint s\n          WHERE (s.consrc ~~* '%ndims(% = %'::text)) sn ON (((sn.connamespace = n.oid) AND (sn.conrelid = c.oid) AND (a.attnum = ANY (sn.conkey)))))\n     LEFT JOIN ( SELECT s.connamespace,\n            s.conrelid,\n            s.conkey,\n            (replace(replace(split_part(s.consrc, ' = '::text, 2), ')'::text, ''::text), '('::text, ''::text))::integer AS srid\n           FROM pg_constraint s\n          WHERE (s.consrc ~~* '%srid(% = %'::text)) sr ON (((sr.connamespace = n.oid) AND (sr.conrelid = c.oid) AND (a.attnum = ANY (sr.conkey)))))\n  WHERE ((c.relkind = ANY (ARRAY['r'::\"char\", 'v'::\"char\", 'm'::\"char\", 'f'::\"char\", 'p'::\"char\"])) AND (NOT (c.relname = 'raster_columns'::name)) AND (t.typname = 'geometry'::name) AND (NOT pg_is_other_temp_schema(c.relnamespace)) AND has_table_privilege(c.oid, 'SELECT'::text))");

=head1 ACCESSORS

=head2 f_table_catalog

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 f_table_schema

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_table_name

  data_type: 'name'
  is_nullable: 1
  size: 64

=head2 f_geometry_column

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

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "f_table_catalog",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "f_table_schema",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_table_name",
  { data_type => "name", is_nullable => 1, size => 64 },
  "f_geometry_column",
  { data_type => "name", is_nullable => 1, size => 64 },
  "coord_dimension",
  { data_type => "integer", is_nullable => 1 },
  "srid",
  { data_type => "integer", is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-21 22:01:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8MYPNBHwSA+bNxsu8EjZZQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
