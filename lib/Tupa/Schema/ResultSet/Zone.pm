package Tupa::Schema::ResultSet::Zone;

use utf8;
use strict;
use warnings;
use feature 'state';
use Moose;

use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::ResultSet';
with 'MyApp::Schema::Role::InflateAsHashRef';
with 'MyApp::Schema::Role::Paging';

sub with_district_count {
  my ($self) = @_;
  $self->search_rs(
    undef,
    {
      '+columns' => [
        {district_count => {count => 'districts.id', -as => 'district_count'}},
      ],
      distinct => 1,
      join     => 'districts',
    }
  );
}

sub with_districts {
  my ($self) = @_;
  $self->search_rs(
    undef,
    {
      '+columns' => [qw(districts.name districts.id districts.slug)],
      collapse   => 1,
      join       => 'districts',
    }
  );
}

sub no_geo {
  my $self = shift;
  my $me   = $self->current_source_alias;
  $self->search_rs(undef, {columns => [qw(id name)]});
}


sub filter {
  my ($self, %args) = @_;
  my $rs = $self->search_rs({});
  my $me = $self->current_source_alias;
  $rs
    = $rs->search_rs(
    {"$me.name" => {-ilike => \[q{'%' || ? || '%'}, [_q => $args{name}]]}})
    if $args{name} && length($args{name}) > 0;

  $rs
    = $rs->search_rs(
    {"$me.code" => {-ilike => \[q{'%' || ? || '%'}, [_q => $args{code}]]}})
    if $args{code} && length($args{code}) > 0;

  $rs;
}

1;

