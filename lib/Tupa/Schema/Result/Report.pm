use utf8;
package Tupa::Schema::Result::Report;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::Report

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

=head1 TABLE: C<report>

=cut

__PACKAGE__->table("report");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'report_id_seq'

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 level

  data_type: 'text'
  is_nullable: 0

=head2 reported_ts

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 reporter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 location

  data_type: 'geometry'
  is_nullable: 1
  size: '58880,16'

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "report_id_seq",
  },
  "description",
  { data_type => "text", is_nullable => 1 },
  "level",
  { data_type => "text", is_nullable => 0 },
  "reported_ts",
  { data_type => "timestamp", is_nullable => 1 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "reporter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "location",
  { data_type => "geometry", is_nullable => 1, size => "58880,16" },
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
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 reporter

Type: belongs_to

Related object: L<Tupa::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "reporter",
  "Tupa::Schema::Result::User",
  { id => "reporter_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-09-05 16:07:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rI/sq0m7sVB0szCWYyGEJQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->might_have(
  "district",
  "Tupa::Schema::Result::District",
  sub {
    my $args = shift;
    return \
      qq{ST_Intersects($args->{foreign_alias}.geom, $args->{self_alias}.location)};
  },
  {is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION"},
);


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

__PACKAGE__->meta->make_immutable;


1;
