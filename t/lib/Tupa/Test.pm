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


1;
