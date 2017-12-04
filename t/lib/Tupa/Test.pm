package Tupa::Test;

use strict;
use warnings;
use Monkey::Patch::Action qw(patch_package);
use feature 'say';
use File::Slurp qw(read_file);
use Data::Fake qw(Core Names Internet);

sub import {

  strict->import;
  warnings->import;

  no strict 'refs';

  my $caller = caller;

  while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } ) {
    next if $name eq 'BEGIN';     # don't export BEGIN blocks
    next if $name eq 'import';    # don't export this sub
    next unless *{$symbol}{CODE}; # export subs only

    my $imported = $caller . '::' . $name;
    *{$imported} = \*{$symbol};
  }
}

sub db_transaction (&) {
  my ( $subref, $modelname ) = @_;

  my $schema = Tupa::Web::App->model( $modelname || 'DB' );

  eval {
    $schema->txn_do(
      sub {
        $subref->($schema);
        die 'rollback';
      }
    );
  };

  die $@ unless $@ =~ /rollback/;
}

sub __new_user {
  my $schema = shift || Tupa::Web::App->model('DB')->schema;
  my $fake_user = fake_hash(
    {
      name         => fake_name(),
      email        => fake_email(),
      password     => fake_digits('a###########b'),
      phone_number => fake_digits('+############'),
    }
  );
  my $user =   $schema->resultset('User')->create( $fake_user->() );
  $user->discard_changes;
  $user;

}

sub __new_session {
  my $schema = shift || Tupa::Web::App->model('DB')->schema;

  __new_user($schema)->reset_session;
}

our ( $in, $out );

if ( $ENV{TRACE} ) {
  use HTTP::Request;
  use HTTP::Response;
  use Term::ANSIColor qw(:constants);
  local $Term::ANSIColor::AUTORESET = 1;
  $out = patch_package(
    'Catalyst::Engine',
    finalize_body => wrap => sub {
      my $__ctx = shift;
      my ( $app, $c ) = @_;
      my $ret = $__ctx->{orig}->(@_);
      my $req = $c->req;
      my $res = $c->res;

      print BOLD BLUE "------------REQUEST-------------\n";

      say HTTP::Request->new( $req->method, $req->uri, $req->headers,
        ref $req->body eq 'File::Temp'
        ? read_file( $req->body->filename )
        : $req->body )->as_string;
      print BOLD RED "------------RESPONSE------------\n";
      say HTTP::Response->new( $res->code, $res->status, $res->headers,
        $res->body )->as_string;
      return $ret;
    }
  );
}

1;
