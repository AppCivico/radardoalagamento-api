package Tupa::Schema::ResultSet::Sensor;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

use Data::Verifier;
use Tupa::Types qw(PluviOnPayload);

has schema => (is => 'ro', lazy => 1, builder => '__build_schema');

sub __build_schema {
  shift->result_source->schema;
}

sub BUILDARGS { $_[2] }

sub verifiers_specs {
  my $self = shift;
  return +{
    pluvion => Data::Verifier->new(
      filters => [qw(trim)],
      profile =>
        {payload => {required => 1, coerce => 1, type => PluviOnPayload,},}
    )
  };
}

sub action_specs {
  my $self = shift;
  return +{
    foo     => 1,
    pluvion => sub {
      my %values = shift->valid_values;
      my $pluvion_source
        = $self->result_source->schema->resultset('SensorSource')
        ->find_or_create({name => 'PluviOn'});
      my $reads  = delete $values{payload}->{reads};
      my $ts     = delete $values{payload}->{timestamp};
      my $sensor = $pluvion_source->sensors->update_or_create($values{payload});

    }
  };
}


sub with_geojson {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      'columns'  => [grep { !/location/ } $self->result_source->columns],
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

