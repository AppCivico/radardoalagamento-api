package Tupa::Schema::ResultSet::Sensor;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

sub with_geojson {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      'columns'  => [grep      { !/location/ } $self->result_source->columns],
      '+columns' => [{location => \"ST_AsGeoJSON($me.location)"}],

    }
  );
}

sub summary {
  shift->search_rs(undef, {prefetch => 'source'});
}


sub filter {
  my ($self, %args) = @_;
  my $rs = $self->search_rs({});
  my $me = $self->current_source_alias;
  $rs = $rs->search_rs(
    {
      "$me.description" =>
        {-ilike => \[q{'%' || ? || '%'}, [_q => $args{description}]]}
    }
  ) if $args{description} && length($args{description}) > 0;

  $rs
    = $rs->search_rs(
    {"$me.name" => {-ilike => \[q{'%' || ? || '%'}, [_q => $args{name}]]}})
    if $args{name} && length($args{name}) > 0;

  $rs;
}


1;

