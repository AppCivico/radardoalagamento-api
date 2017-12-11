package Tupa::Schema::ResultSet::AppReport;

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

use Tupa::Types qw( AppReportStatus);
use MooseX::Types::Common::String qw(NonEmptyStr);
use Data::Verifier;
use Safe::Isa;

has schema => ( is => 'ro', lazy => 1, builder => '__build_schema' );

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
        payload => {
          required => 1,
          type     => NonEmptyStr,
        },
        status => {
          required => 1,
          type     => AppReportStatus,
        }
      }
    )
  };
}

sub action_specs {
  my $self = shift;
  return +{
    create => sub {
      $self->create( { shift->valid_values } );
    },
  };
}

sub summary {

  my ($self) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      rows     => 100,
      order_by => { -desc => "$me.create_ts" }
    }
  );
}

1;
