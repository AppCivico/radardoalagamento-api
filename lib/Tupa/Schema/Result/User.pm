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

=head2 app_reports

Type: has_many

Related object: L<Tupa::Schema::Result::AppReport>

=cut

__PACKAGE__->has_many(
  "app_reports",
  "Tupa::Schema::Result::AppReport",
  { "foreign.user_id" => "self.id" },
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

=head2 user_roles

Type: has_many

Related object: L<Tupa::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Tupa::Schema::Result::UserRole",
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


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-12-11 11:50:07
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2P3SCvPFSv5cBDADydGICQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->many_to_many( roles => user_roles => 'role' );

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

with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';

use MooseX::Types::Email qw/EmailAddress/;
use Tupa::Types qw(MobileNumber);
use Data::Verifier;
use Authen::Passphrase::AcceptAll;

has schema => ( is => 'ro', lazy => 1, builder => '__build_schema' );

sub __build_schema {
  shift->result_source->schema;
}

sub verifiers_specs {
  my $self = shift;

  return {
    update => Data::Verifier->new(
      filters => [qw(trim)],
      profile => {
        push_token => {
          required => 0,
          type     => 'Str',
        },
        name => {
          required => 0,
          type     => 'Str',
        },
        phone_number => {
          required   => 0,
          type       => MobileNumber,
          post_check => sub {
            my $r = shift;
            die { msg_id => 'phone_number_already_exists', type => 'deafult' }
              if (
              $self->find(
                {
                  active       => 1,
                  phone_number => $r->get_value('phone_number')
                }
              )
              );
            return 1;
          }
        },
        districts => {
          required   => 0,
          type       => 'Maybe[ArrayRef[Int]]',
          post_check => sub {
            my $r   = shift;
            my $ids = $r->get_value('districts');
            return 1 unless scalar @$ids;
            return $self->schema->resultset('District')
              ->search_rs( { id => { -in => $ids } } )->count == scalar @$ids;

          }
        },
        password => {
          required   => 0,
          type       => 'Str',
          min_length => 8,
          dependent  => {
            password_confirmation => {
              required   => 0,
              min_length => 8,
              type       => 'Str',
            },
          },
          post_check => sub {
            my $r = shift;
            return $r->get_value('password') eq
              $r->get_value('password_confirmation');
          },
        }
      }
      )

  };
}

sub action_specs {
  my $self = shift;
  return {
    update => sub {
      my %values = shift->valid_values;

      not defined $values{$_} and delete $values{$_} for keys %values;

      delete $values{password_confirmation};
      my $districts = delete $values{districts} || [];

      $values{password} ||= Authen::Passphrase::AcceptAll->new;

      $self->set_districts( $self->schema->resultset('District')
          ->search_rs( { id => { -in => $districts } } )->all )
        if @$districts;

      $self->result_source->resultset->kick_push_token( $values{push_token} )
        if $values{push_token};
      $self->update( \%values );
      $self->discard_changes;
      $self;
    }
  };
}

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

sub TO_JSON {
  my %data = shift->get_columns;
  delete $data{password};
  delete $data{push_token};

  \%data;
}

__PACKAGE__->meta->make_immutable;

1;
