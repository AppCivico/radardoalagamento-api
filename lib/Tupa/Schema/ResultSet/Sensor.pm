package Tupa::Schema::ResultSet::Sensor;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';

sub with_geojson {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      'columns' => [ grep { !/location/ } $self->result_source->columns ],
      '+columns' => [ { location => \"ST_AsGeoJSON($me.location)" } ],

    }
  );
}

sub summary {
  shift->search_rs( undef, { prefetch => 'source' } );
}
1;

