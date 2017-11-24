package Tupa::Test;

use strict;
use warnings;
use Monkey::Patch::Action qw(patch_package);
use feature 'say';
use File::Slurp qw(read_file);

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
  my $schema = shift;
  $schema->resultset('User')->create(
    {
      name     => 'Foo ' . rand(),
      email    => 'email.' . ( int( rand(100000) ) ) . '@emailfake.com',
      password => 1234,
    }
  );
}

sub __new_session {
  my $schema = shift;
  __new_user($schema)->reset_session;
}

our ( $in, $out );

if ( $ENV{TRACE} ) {
  use HTTP::Request;
  use HTTP::Response;
  $out = patch_package(
    'Catalyst::Engine',
    finalize_body => wrap => sub {
      my $__ctx = shift;
      my ( $app, $c ) = @_;
      my $ret = $__ctx->{orig}->(@_);
      my $req = $c->req;
      my $res = $c->res;

      say '------------REQUEST-------------';

      say HTTP::Request->new( $req->method, $req->uri, $req->headers,
        ref $req->body eq 'File::Temp' ? read_file( $req->body->filename ) : $req->body )->as_string;
      say '------------RESPONSE------------';
      say HTTP::Response->new( $res->code, $res->status, $res->headers,
        $res->body )->as_string;
      return $ret;
    }
  );
}

1;
