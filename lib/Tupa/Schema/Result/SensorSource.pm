use utf8;
package Tupa::Schema::Result::SensorSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::SensorSource

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

=head1 TABLE: C<sensor_source>

=cut

__PACKAGE__->table("sensor_source");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'sensor_source_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

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
    sequence          => "sensor_source_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sensor_source_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("sensor_source_name_key", ["name"]);

=head1 RELATIONS

=head2 sensors

Type: has_many

Related object: L<Tupa::Schema::Result::Sensor>

=cut

__PACKAGE__->has_many(
  "sensors",
  "Tupa::Schema::Result::Sensor",
  { "foreign.source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-23 11:21:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M5G0tJaOKxEuxFIXEyziGQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
