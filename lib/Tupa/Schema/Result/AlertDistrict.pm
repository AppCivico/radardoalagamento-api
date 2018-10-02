use utf8;
package Tupa::Schema::Result::AlertDistrict;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::AlertDistrict

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

=head1 TABLE: C<alert_district>

=cut

__PACKAGE__->table("alert_district");

=head1 ACCESSORS

=head2 alert_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 district_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "alert_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "district_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<alert_district_alert_id_district_id_key>

=over 4

=item * L</alert_id>

=item * L</district_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "alert_district_alert_id_district_id_key",
  ["alert_id", "district_id"],
);

=head1 RELATIONS

=head2 alert

Type: belongs_to

Related object: L<Tupa::Schema::Result::Alert>

=cut

__PACKAGE__->belongs_to(
  "alert",
  "Tupa::Schema::Result::Alert",
  { id => "alert_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 district

Type: belongs_to

Related object: L<Tupa::Schema::Result::District>

=cut

__PACKAGE__->belongs_to(
  "district",
  "Tupa::Schema::Result::District",
  { id => "district_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-12-14 15:08:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aA3OHYlip/OCyIbq67YAww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
