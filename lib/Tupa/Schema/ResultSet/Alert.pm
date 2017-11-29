package Tupa::Schema::ResultSet::Alert;

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

use Tupa::Types qw(MobileNumber AlertLevel);
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
        description => {
          required => 0,
          type     => 'Str',
        },
        __user => {
          required => 1
        },
        sensor_sample_id => {
          required   => 1,
          type       => 'Int',
          post_check => sub {
            my $r = shift;
            return $self->schema->resultset('SensorSample')
              ->find( $r->get_value('sensor_sample_id') );
          }
        },
        level => {
          required => 1,
          type     => AlertLevel,
          filters  => [qw(lower trim)],
        }
      }
    )
  };
}

sub action_specs {
  my $self = shift;
  return +{
    oi     => sub { },
    create => sub {
      my %values = shift->valid_values;

      my $alert = $self->create(
        {
          reporter => ( delete $values{__user} )->{obj},
          %values
        }
      );
      eval { $alert->notify };
      warn $@ if $@;
      $alert->update( { pushed_to_users => 1 } );
      $alert;
    },
  };
}

sub summary {
  my ($self) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      prefetch => { sensor_sample => 'sensor' },
      order_by => { -desc         => "$me.created_at" }
    }
  );
}

1;
