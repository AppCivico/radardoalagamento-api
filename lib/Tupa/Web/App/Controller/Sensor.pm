package Tupa::Web::App::Controller::Sensor;

use utf8;
use Moose;
use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/) PathPart(sensor) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{collection} = $c->model('DB::Sensor');
}

sub object : Chained(base) : PathPart('') : CaptureArgs(Int) {
  my ( $self, $c, $id ) = @_;
  $c->stash->{object} = $c->stash->{collection}->find($id)
    or $c->detach('/error_404');
}

sub view : Chained(object) : PathPart('') :Args(0) : GET {
  my ( $self, $c ) = @_;
  $self->status_ok( $c, entity => $c->stash->{object} );
}

sub list : Chained(base) PathPart('') Args(0) GET {
  my ( $self, $c ) = @_;

  $self->status_ok(
    $c,
    entity => {
      results =>
        [ $c->stash->{collection}->as_hashref->all ]
    }
  );
}

sub sample : Chained(object) Args(0) GET {
  my ( $self, $c ) = @_;

  $self->status_ok(
    $c,
    entity => {
      results => [ $c->stash->{object}->samples->as_hashref->all ]
    }
  );
}

__PACKAGE__->meta->make_immutable;

1;
