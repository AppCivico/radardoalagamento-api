use utf8;

package Tupa::Schema::Result::Sensor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::Sensor

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

=head1 TABLE: C<sensor>

=cut

__PACKAGE__->table("sensor");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sensor_id_seq'

=head2 source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 sensor_type

  data_type: 'text'
  is_nullable: 1

=head2 location

  data_type: 'geometry'
  is_nullable: 1
  size: '58880,16'

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sensor_id_seq",
  },
  "source_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "name",
  {data_type => "text", is_nullable => 0},
  "description",
  {data_type => "text", is_nullable => 1},
  "sensor_type",
  {data_type => "text", is_nullable => 1},
  "location",
  {data_type => "geometry", is_nullable => 1, size => "58880,16"},
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => {default_value => \"now()"},
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sensor_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("sensor_name_key", ["name"]);

=head1 RELATIONS

=head2 sensor_samples

Type: has_many

Related object: L<Tupa::Schema::Result::SensorSample>

=cut

__PACKAGE__->has_many(
  "sensor_samples",
  "Tupa::Schema::Result::SensorSample",
  {"foreign.sensor_id" => "self.id"},
  {cascade_copy        => 0, cascade_delete => 0},
);

=head2 source

Type: belongs_to

Related object: L<Tupa::Schema::Result::SensorSource>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Tupa::Schema::Result::SensorSource",
  {id            => "source_id"},
  {is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION"},
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-09-05 16:07:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FGI6luZvQvdPFG+3JKWe5A

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->has_many(
  "samples",
  "Tupa::Schema::Result::SensorSample",
  {"foreign.sensor_id" => "self.id"},
  {cascade_copy        => 0, cascade_delete => 0},
);

use Moo;
with 'MooX::Role::JSON_LD';
sub json_ld_type   {'Sensor'}
sub json_ld_fields { [qw[ id name sensor_type]] }

sub _build_context {
  return 'http://hello.org/';
}

sub TO_JSON {
  my $self = shift;
  my $data = +{
    $self->get_from_storage(
      {
        columns    => [grep { !/location/ } $self->result_source->columns],
        '+columns' => [{location => \'ST_AsGeoJSON(location)'}],
      }
    )->get_columns
  };
  $data->{sensor_type} = delete $data->{type};
  $data;
}

__PACKAGE__->has_many(
  "districts",
  "Tupa::Schema::Result::District",
  sub {
    my $args = shift;
    return \
      qq{ST_Intersects($args->{foreign_alias}.geom, $args->{self_alias}.location)};

    # return { "$args->{foreign_alias}.geom" =>
    #     { '&&' => { -ident => "$args->{self_alias}.location" } }, };
  },
  {cascade_copy => 0, cascade_delete => 0, join_type => 'LEFT'},
);

__PACKAGE__->meta->make_immutable;

1;
