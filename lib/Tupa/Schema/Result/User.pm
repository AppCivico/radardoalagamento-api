use utf8;
package Tupa::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 phone_number

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 create_ts

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 active

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

=head2 push_token

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "phone_number",
  { data_type => "text", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "create_ts",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
  "push_token",
  { data_type => "text", is_nullable => 1 },
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
  { "foreign.reporter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_districts

Type: has_many

Related object: L<Tupa::Schema::Result::UserDistrict>

=cut

__PACKAGE__->has_many(
  "user_districts",
  "Tupa::Schema::Result::UserDistrict",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_sessions

Type: has_many

Related object: L<Tupa::Schema::Result::UserSession>

=cut

__PACKAGE__->has_many(
  "user_sessions",
  "Tupa::Schema::Result::UserSession",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-11-24 18:36:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Rgsgvxvig62ZvkK3gojkfQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->remove_column('password');

__PACKAGE__->load_components(qw(PassphraseColumn));

__PACKAGE__->add_column(
  password => {
    data_type        => "text",
    passphrase       => 'crypt',
    passphrase_class => 'BlowfishCrypt',
    passphrase_args  => {
      cost        => 8,
      salt_random => 1,
    },
    passphrase_check_method => 'check_password',
    is_nullable             => 0
  },
);

__PACKAGE__->many_to_many( districts => user_districts => 'district' );

sub reset_session {
  my ($self) = @_;
  $self->user_sessions->update( { valid_until => \q|now()| } );
  $self->user_sessions->create( {} )->discard_changes;
}

sub follow {
  my ( $self, $district ) = @_;
  $self->add_to_districts($district);
}

sub unfollow {
  my ( $self, $district ) = @_;
  $self->remove_from_districts($district);
}

__PACKAGE__->meta->make_immutable;

1;
