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
with 'MyApp::Schema::Role::Paging';

use Tupa::Types qw(MobileNumber AlertLevel);
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
      derived => {
        source => {
          required => 1,
          fields   => [qw(sensor_sample_id districts)],
          deriver  => sub {
            my $r = shift;
            die {msg_id => 'alert_source_missing', type => 'default'}
              unless $r->get_value('sensor_sample_id')
              || $r->get_value('districts');
            return 1;
          }
        }
      },
      profile => {
        description      => {required => 0, type => 'Str',},
        __user           => {required => 1},
        sensor_sample_id => {
          required   => 0,
          type       => 'Int',
          post_check => sub {
            my $r = shift;
            return $self->schema->resultset('SensorSample')
              ->find($r->get_value('sensor_sample_id'));
          }
        },
        districts => {
          required   => 0,
          type       => 'Maybe[ArrayRef[Int]]',
          post_check => sub {
            my $r   = shift;
            my $ids = $r->get_value('districts');
            return 1 unless scalar @$ids;
            return $self->schema->resultset('District')
              ->search_rs({id => {-in => $ids}})->count == scalar @$ids;

          }
        },
        level =>
          {required => 1, type => AlertLevel, filters => [qw(lower trim)],}
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
      my $districts = delete $values{districts} || [];

      delete $values{source};
      my $alert
        = $self->create({reporter => (delete $values{__user})->{obj}, %values});

      $alert->set_districts($self->schema->resultset('District')
          ->search_rs({id => {-in => $districts}})->all)
        if scalar @$districts;

      eval { $alert->notify };
      $alert->update({pushed_to_users => 1});
      $alert;
    },
  };
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

  $rs = $rs->search_rs({"$me.level" => $args{level}})
    if $args{level} && scalar grep { $args{level} eq $_ }
    ('attention', 'alert', 'emergency', 'overflow');

  $rs = $rs->search_rs(
    {
      "sensor.name" =>
        {-ilike => \[q{'%' || ? || '%'}, [_q => $args{'sensor.name'}]]}
    },
    {join => {sensor_sample => 'sensor'}}
  ) if $args{'sensor.name'};
  $rs;
}

sub summary {

  my ($self) = @_;
  my $me = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      prefetch => [
        {alert_districts => 'district'},
        {sensor_sample   => {'sensor' => 'districts'}}
      ],
      order_by => {-desc => "$me.created_at"}
    }
  );
}

1;
