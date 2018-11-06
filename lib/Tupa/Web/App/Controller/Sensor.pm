package Tupa::Web::App::Controller::Sensor;

use utf8;
use Moose;
use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/base) PathPart(sensor) CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection} = $c->model('DB::Sensor');
}

sub pluvion : Chained(base) : Args(0) POST {
  my ($self, $c) = @_;

  $self->status_created(
    $c,
    location => $c->req->uri->as_string,
    entity =>
      scalar $c->stash->{collection}
      ->execute($c, for => pluvion => with => {payload => {%{$c->req->data}}},)
  );
}


sub object : Chained(base) : PathPart('') : CaptureArgs(Int) {
  my ($self, $c, $id) = @_;
  $c->stash->{object} = $c->stash->{collection}->find($id)
    or $c->detach('/error_404');
}

sub view : Chained(object) : PathPart('') : Args(0) : GET {
  my ($self, $c) = @_;
  $self->status_ok($c, entity => $c->stash->{object});
}

sub alert : Chained(object) : Args(0) : GET {
  my ($self, $c) = @_;
  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results => [
        $c->stash->{object}->samples->related_resultset('alerts')
          ->summary->as_hashref
      ]
    )
  );
}


sub list : Chained(base) PathPart('') Args(0) GET {
  my ($self, $c) = @_;

  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results =>
        [$c->stash->{collection}->summary->with_geojson->as_hashref]
    )
  );
}

sub sample : Chained(object) Args(0) GET {
  my ($self, $c) = @_;

  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results =>
        [$c->stash->{object}->samples->with_geojson->summary->as_hashref]
    )
  );
}

__PACKAGE__->meta->make_immutable;

1;
