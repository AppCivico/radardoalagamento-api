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
      columns    => [grep  { !/geom/ } $self->result_source->columns],
      '+columns' => [{geom => \'ST_AsGeoJSON(geom)'}],
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


1;

