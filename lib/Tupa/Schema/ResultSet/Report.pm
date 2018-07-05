package Tupa::Schema::ResultSet::Report;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Role::Verification';
with 'MyApp::Role::Verification::TransactionalActions::DBIC';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

use Tupa::Types qw(AlertLevel Latitude Longitude);
use MooseX::Types::Common::String qw(NonEmptyStr);
use Types::DateTime -all;
use Data::Verifier;
use Safe::Isa;

has schema => (is => 'ro', lazy => 1, builder => '__build_schema');

sub __build_schema {
  shift->result_source->schema;
}

sub BUILDARGS { $_[2] }

sub verifiers_specs {
  my $self = shift;
  return +{
    create => Data::Verifier->new(
      filters => [qw(trim)],
      profile => {
        description => {required => 0, type => 'Str',},
        reported_ts => {
          required => 0,
          coerce   => 1,
          type     => DateTimeUTC->plus_coercions(Format ['ISO8601'])
        },
        __user => {required => 1},
        level =>
          {required => 1, type => AlertLevel, filters => [qw(lower trim)],},

        lat => {required => 1, type => Latitude,  coerce => 1},
        lng => {required => 1, type => Longitude, coerce => 1},
      },
      derived => {
        location => {
          required => 1,
          fields   => [qw(lat lng)],
          deriver  => sub {
            my $r = shift;
            return \(
              sprintf(
                qq{'SRID=4326;POINT(%s %s)::geography'},
                $r->get_value('lng'),
                $r->get_value('lat')
              )
            );
          }
        },
      }
    )
  };
}

sub action_specs {
  my $self = shift;
  return +{
    create => sub {
      my %values = shift->valid_values;
      delete @values{qw(lat lng)};
      my $report
        = $self->create({reporter => (delete $values{__user})->{obj}, %values});
      $report->discard_changes;
      $report;
    },
  };
}
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
  my ($self) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs(undef,
    {rows => 100, order_by => [{-desc => "$me.created_at"}]});
}

1;
