use utf8;
package Tupa::Schema::Result::SpatialRefSy;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::SpatialRefSy

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

=head1 TABLE: C<spatial_ref_sys>

=cut

__PACKAGE__->table("spatial_ref_sys");

=head1 ACCESSORS

=head2 srid

  data_type: 'integer'
  is_nullable: 0

=head2 auth_name

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 auth_srid

  data_type: 'integer'
  is_nullable: 1

=head2 srtext

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=head2 proj4text

  data_type: 'varchar'
  is_nullable: 1
  size: 2048

=cut

__PACKAGE__->add_columns(
  "srid",
  { data_type => "integer", is_nullable => 0 },
  "auth_name",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "auth_srid",
  { data_type => "integer", is_nullable => 1 },
  "srtext",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
  "proj4text",
  { data_type => "varchar", is_nullable => 1, size => 2048 },
);

=head1 PRIMARY KEY

=over 4

=item * L</srid>

=back

=cut

__PACKAGE__->set_primary_key("srid");


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-21 22:01:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E4VeJMgQmTk4d3Ia5kYUfA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
