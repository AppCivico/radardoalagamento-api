package Tupa::Web::App::Controller::District;

use utf8;
use Moose;
use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/base) PathPart(district) CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection} = $c->model('DB::District');
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

sub list : Chained(base) PathPart('') Args(0) GET {
  my ($self, $c) = @_;

  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results => [$c->stash->{collection}->summary->as_hashref]
    )
  );
}

sub follow : Chained(object) Args(0) POST {
  my ($self, $c) = @_;
  $c->forward('/try_login');
  $c->user->follow($c->stash->{object});
  $self->status_accepted($c, entity => $c->stash->{object});
}

sub unfollow : Chained(object) Args(0) POST {
  my ($self, $c) = @_;
  $c->forward('/try_login');
  $c->user->unfollow($c->stash->{object});
  $self->status_accepted($c, entity => $c->stash->{object});
}

sub sensor : Chained(object) Args(0) GET {
  my ($self, $c) = @_;
  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results =>
        [$c->stash->{object}->sensors->with_geojson->summary->as_hashref]
    )
  );
}

__PACKAGE__->meta->make_immutable;

1;
