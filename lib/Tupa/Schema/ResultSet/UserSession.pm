package Tupa::Schema::ResultSet::UserSession;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';

has schema => ( is => 'ro', lazy => 1, builder => '__build_schema' );

sub __build_schema {
  shift->result_source->schema;
}

sub BUILDARGS { $_[2] }

sub valid {
  my ($self) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs( { valid_until => { '>' => \'now()' } } );
}

1;
