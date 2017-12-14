use utf8;
package Tupa::Schema::Result::District;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::District

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

=head1 TABLE: C<district>

=cut

__PACKAGE__->table("district");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'district_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 slug

  data_type: 'text'
  is_nullable: 0

=head2 geom

  data_type: 'geometry'
  is_nullable: 1
  size: '58888,16'

=head2 zone_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "district_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "slug",
  { data_type => "text", is_nullable => 0 },
  "geom",
  { data_type => "geometry", is_nullable => 1, size => "58888,16" },
  "zone_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 alerts

Type: has_many

Related object: L<Tupa::Schema::Result::Alert>

=cut

__PACKAGE__->has_many(
  "alerts",
  "Tupa::Schema::Result::Alert",
  { "foreign.district_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_districts

Type: has_many

Related object: L<Tupa::Schema::Result::UserDistrict>

=cut

__PACKAGE__->has_many(
  "user_districts",
  "Tupa::Schema::Result::UserDistrict",
  { "foreign.district_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 zone

Type: belongs_to

Related object: L<Tupa::Schema::Result::Zone>

=cut

__PACKAGE__->belongs_to(
  "zone",
  "Tupa::Schema::Result::Zone",
  { id => "zone_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-12-14 11:49:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7gHfc5EoWsQQJ3Tc73M6dA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->remove_column('geom');

__PACKAGE__->add_column(
  "geom",
  {
    data_type     => "geometry",
    is_nullable   => 1,
    size          => "58888,16",
    remove_column => 1,
  }
);

__PACKAGE__->has_many(
  "sensors",
  "Tupa::Schema::Result::Sensor",
  sub {
    my $args = shift;
    return { "$args->{foreign_alias}.location" =>
        { '&&' => { -ident => "$args->{self_alias}.geom" } }, };
  },
  { cascade_copy => 0, cascade_delete => 0, join_type => 'LEFT' },
);

sub TO_JSON {
  my $self = shift;
  +{
    $self->get_from_storage(
      {
        columns => [ grep { !/geom/ } $self->result_source->columns ],
        '+columns' => [ { geom => \'ST_AsGeoJSON(geom)' } ],
      }
    )->get_columns
  };
}

__PACKAGE__->meta->make_immutable;
1;
