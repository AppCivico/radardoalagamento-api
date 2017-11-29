use utf8;

package Tupa::Web::App;
use strict;
use warnings;

use v5.14.0;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use Catalyst qw/
  ConfigLoader
  Authentication
  Authorization::Roles
  EnableMiddleware
  I18N
  /;

extends 'Catalyst';
use JSON qw();

my $json = JSON->new->utf8(1)->pretty(1)->convert_blessed(1)->allow_blessed(1);

__PACKAGE__->config(
  name                   => 'Tupa::Web::App',
  enable_catalyst_header => 0,
  utf8                   => 1,
  encoding               => 'UTF-8',
  plugin                 => {
    Authentication => {
      default_realm => 'default',
      realms        => {
        default => {
          credential => {
            class          => 'Password',
            password_field => 'password',
            password_type  => 'self_check'
          },
          store => {
            class         => 'DBIx::Class',
            user_model    => 'DB::User',
            role_relation => 'roles',
            role_field    => 'name'
          }
        }
      }
    }
  }
);

# after setup_finalize => sub {
#   my $app = shift;
#   $_->{map} = {

#     %{ $_->{map} || {} },
#     'application/json' => [
#       'Callback',
#       {
#         deserialize => sub {
#           $json->decode(shift);
#         },
#         serialize => sub {
#           my $x = shift;
#           $json->encode($x);
#         }
#       }
#     ]
#     }
#     for grep { $_->isa('Tupa::Web::App::Controller') }
#     map      { $app->controller($_) } $app->controllers;
#   }
#   if $ENV{HARNESS_ACTIVE};

__PACKAGE__->setup();

sub build_api_error {
  my ( $app, %args ) = @_;
  my $msg_id         = $args{msg_id};
  my $explain_msg_id = $msg_id . '__explain';
  my %err;

  $err{internal_msg_id} = $msg_id;
  $err{short_message}   = $app->loc($msg_id);

  if ( $err{short_message} eq $msg_id ) {
    if ( $msg_id =~ /_missing$/ ) {
      $msg_id =~ s/_missing/_invalid/;
      $err{internal_msg_id} = $msg_id;
      $err{short_message}   = $app->loc($msg_id);
    }
  }
  $err{message} = $app->loc($explain_msg_id);

  $err{message} = $err{short_message} if $err{message} eq $explain_msg_id;

  if ( $err{message} eq $explain_msg_id || $err{message} eq $msg_id ) {

    # my $hostname = `hostname`;
    # chomp($hostname);
    # eval {
    #   $app->slack_notify(
    #     sprintf(
    #       "Faltando traducao para msg_id=$msg_id [hostname=%s] [%s]",
    #       $hostname,
    #       $app->req->uri->path_query . ' ' . trim( Dumper( $app->req->data ) )
    #     ),
    #     channel => '#api-error'
    #   );
    # };
    warn "Error caught while procesing request: $@" if $@;
  }

  $err{type} = $args{type} || 'default';

  $err{form_field} = $args{form_field} if $args{form_field};

  $err{extra} = delete $args{extra} if exists $args{extra};

  $err{context} = delete $args{context} if exists $args{context};

  return \%err;
}

__PACKAGE__->meta->make_immutable;

1;
