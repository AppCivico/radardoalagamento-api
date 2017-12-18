package Tupa::Schema::ResultSet::User;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

use MooseX::Types::Email qw/EmailAddress/;
use Tupa::Types qw(MobileNumber);
use Data::Verifier;
use Safe::Isa;
use Authen::Passphrase::AcceptAll;

has schema => ( is => 'ro', lazy => 1, builder => '__build_schema' );

sub __build_schema {
  shift->result_source->schema;
}

sub BUILDARGS { $_[2] }

sub verifiers_specs {
  my $self   = shift;
  my $create = Data::Verifier->new(
    filters => [qw(trim)],
    profile => {
      push_token => {
        required => 1,
        type     => 'Str',
      },
      name => {
        required => 1,
        type     => 'Str',
      },
      email => {
        required   => 0,
        type       => EmailAddress,
        filters    => [qw(lower trim flatten)],
        post_check => sub {
          my $r = shift;
          return 0
            if (
            $self->find(
              {
                active => 1,
                email  => $r->get_value('email')
              }
            )
            );
          return 1;
        }
      },
      phone_number => {
        required   => 1,
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
  );

  return {
    login => Data::Verifier->new(
      filters => [qw(trim)],
      profile => {
        email => {
          required   => 1,
          type       => EmailAddress,
          filters    => [qw(lower trim)],
          post_check => sub {
            my $r = shift;
            die { msg_id => 'login_invalid', type => 'default' }
              unless
              defined $self->search_rs( { email => $r->get_value('email') },
              { rows => 1 } )->single;
            return 1;
          }
        },

        password => {
          required => 1,
          type     => 'Str',
        },
      }
    ),
    create => $create,

    create_admin => Data::Verifier->new(
      filters => [qw(trim)],
      profile => {
        push_token => {
          required => 0,
          type     => 'Str',
        },
        name => {
          required => 1,
          type     => 'Str',
        },
        email => {
          required   => 0,
          type       => EmailAddress,
          filters    => [qw(lower trim flatten)],
          post_check => sub {
            my $r = shift;
            return 0
              if (
              $self->find(
                {
                  active => 1,
                  email  => $r->get_value('email')
                }
              )
              );
            return 1;
          }
        },
        phone_number => {
          required   => 1,
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
          required   => 1,
          type       => 'Str',
          min_length => 8,
          dependent  => {
            password_confirmation => {
              required   => 1,
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
    create => sub {
      my %values = shift->valid_values;
      delete $values{password_confirmation};
      my $districts = delete $values{districts} || [];
      my $token = delete $values{token};
      $values{password} ||= Authen::Passphrase::AcceptAll->new;

      $self->kick_push_token( $values{push_token} ) if $values{push_token};

      my $user = $self->create( \%values );
            
      $user->follow( $self->schema->resultset('District')
          ->search_rs( { id => { -in => $districts } } )->all )
        if @$districts;

      return $user->reset_session;
    },
    create_admin => sub {
      my %values = shift->valid_values;

      delete $values{password_confirmation};
      my $districts = delete $values{districts} || [];

      $values{password} ||= Authen::Passphrase::AcceptAll->new;

      $self->kick_push_token( $values{push_token} ) if $values{push_token};

      my $user = $self->create( \%values );

      $user->follow( $self->schema->resultset('District')
          ->search_rs( { id => { -in => $districts } } )->all )
        if @$districts;

      $user->add_to_roles( { name => 'admin' } );

      return $user->reset_session;
    },

    login => sub {
      my %values = shift->valid_values;

      my $password = delete $values{password};
      my $user =
        $self->search_rs( {%values}, { rows => 1 } )->single;

      die { type => 'default', msg_id => 'user_inactive' }
        unless $user->active;

      die { type => 'default', msg_id => 'login_invalid' }
        if $user
        && ( !$user->password
        || $user->password->$_isa('Authen::Passphrase::RejectAll') );

      die { type => 'default', msg_id => 'login_invalid' }
        unless $user->check_password($password);

      return $user->reset_session;
    },
  };
}

sub kick_push_token {
  my ( $self, $token ) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs( { "$me.push_token" => $token } )
    ->update( { push_token => undef } );
}

1;
