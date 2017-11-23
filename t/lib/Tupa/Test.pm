package Tupa::Test;

use strict;
use warnings;

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

1;
