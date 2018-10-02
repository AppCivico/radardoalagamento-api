use utf8;
package Tupa::Schema::Result::UserSession;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::UserSession

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

=head1 TABLE: C<user_session>

=cut

__PACKAGE__->table("user_session");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 api_key

  data_type: 'uuid'
  default_value: uuid_generate_v4()
  is_nullable: 0
  size: 16

=head2 create_ts

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 valid_until

  data_type: 'timestamp'
  default_value: (now() + '10 years'::interval)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "api_key",
  {
    data_type => "uuid",
    default_value => \"uuid_generate_v4()",
    is_nullable => 0,
    size => 16,
  },
  "create_ts",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "valid_until",
  {
    data_type     => "timestamp",
    default_value => \"(now() + '10 years'::interval)",
    is_nullable   => 0,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<user_session_api_key_key>

=over 4

=item * L</api_key>

=back

=cut

__PACKAGE__->add_unique_constraint("user_session_api_key_key", ["api_key"]);

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-10 11:28:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ascke4Fn9ZM4iCwU3M2RDQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key("api_key");

__PACKAGE__->meta->make_immutable;
1;
