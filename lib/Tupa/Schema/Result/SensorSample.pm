use utf8;
package Tupa::Schema::Result::SensorSample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::SensorSample

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

=head1 TABLE: C<sensor_sample>

=cut

__PACKAGE__->table("sensor_sample");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sensor_sample_id_seq'

=head2 sensor_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'text'
  is_nullable: 0

=head2 location

  data_type: 'geometry'
  is_nullable: 1
  size: '58880,16'

=head2 event_ts

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 extra

  data_type: 'json'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "sensor_sample_id_seq",
  },
  "sensor_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "text", is_nullable => 0 },
  "location",
  { data_type => "geometry", is_nullable => 1, size => "58880,16" },
  "event_ts",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "extra",
  { data_type => "json", is_nullable => 1 },
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
  { "foreign.sensor_sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sensor

Type: belongs_to

Related object: L<Tupa::Schema::Result::Sensor>

=cut

__PACKAGE__->belongs_to(
  "sensor",
  "Tupa::Schema::Result::Sensor",
  { id => "sensor_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-24 09:11:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YVgMN/ncqutWYo+GH1ccLw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;

sub TO_JSON {
  my $self = shift;
  +{
    $self->get_from_storage(
      {
        columns    => [grep { !/location/ } $self->result_source->columns],
        '+columns' => [{location => \'ST_AsGeoJSON(location)'}],
      }
    )->get_columns
  };
}


1;
