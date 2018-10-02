use utf8;
package Tupa::Schema::Result::UserDistrict;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::UserDistrict

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

=head1 TABLE: C<user_district>

=cut

__PACKAGE__->table("user_district");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 district_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "district_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<user_district_user_id_district_id_key>

=over 4

=item * L</user_id>

=item * L</district_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "user_district_user_id_district_id_key",
  ["user_id", "district_id"],
);

=head1 RELATIONS

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

=head2 user

Type: belongs_to

Related object: L<Tupa::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Tupa::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-23 19:05:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YrBqOJSo6n9NjGhQKCdr7g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
