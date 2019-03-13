package Tupa::Schema::ResultSet::District;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';
__PACKAGE__->load_components('Helper::ResultSet::AutoRemoveColumns');

sub summary {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs(
    undef,
    {
      join       => 'sensors',
      distinct   => 1,
      columns    => [grep { !/geom/ } $self->result_source->columns],
      '+columns' => [
        {geom => \'ST_AsGeoJSON(geom)'},
        {
          sensors => {
            array_remove => [{array_agg => 'sensors.id'}, \'NULL'],
            -as          => 'sensors'
          }
        }
      ],
    }
  );

}


sub filter {
  my ($self, %args) = @_;
  my $rs = $self->search_rs({});
  my $me = $self->current_source_alias;
  $rs
    = $rs->search_rs(
    {"$me.name" => {-ilike => \[q{'%' || ? || '%'}, [_q => $args{name}]]}})
    if $args{name} && length($args{name}) > 0;
  $rs;
}

sub with_alerts {
    my ($self, %args) = @_;

    my $rs = $self->search_rs({});
    my $me = $self->current_source_alias;

    $rs = $rs->search_rs(
        { 'alert_districts.district_id' => \'IS NOT NULL' },
        {
			'+columns' => [qw( me.name alert.description alert.level alert.created_at )],
			order_by   => { -desc => 'alert.created_at' },
            collapse   => 0,
			join       => { 'alert_districts' => 'alert' }
        }
    );

    return $rs;
}

1;

