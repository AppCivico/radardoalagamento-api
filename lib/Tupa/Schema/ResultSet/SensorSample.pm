package Tupa::Schema::ResultSet::SensorSample;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

sub BUILDARGS { $_[2] }

sub last {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs( undef,
    { order_by => { -desc => "$me.event_ts" }, rows => 1 } );
}


sub summary {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs( undef,
    { order_by => { -desc => "$me.event_ts" } } );
  
}

1;
