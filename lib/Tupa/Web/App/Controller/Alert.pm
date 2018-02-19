package Tupa::Web::App::Controller::Alert;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/logged_in) PathPart(alert) CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection}
    = $c->user->obj->user_districts->related_resultset('district')
    ->related_resultset('alert_districts')->related_resultset('alert');
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

sub reported : Chained(base) Args(0) GET {
  my ($self, $c) = @_;

  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results => [$c->user->obj->alerts->summary->as_hashref]
    )
  );
}


sub all : Chained(base) Args(0) GET {
  my ($self, $c) = @_;

  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results => [$c->model('DB::Alert')->summary->as_hashref]
    )
  );
}

__PACKAGE__->meta->make_immutable;

1;
