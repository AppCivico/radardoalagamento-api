package Tupa::Web::App::Controller::Report;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/logged_in) PathPart('report') CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection} = $c->model('DB::Report');
}

sub report : Chained(base) : PathPart('') Args(0) POST {
  my ($self, $c) = @_;
  $self->status_created(
    $c,
    location => $c->req->uri->as_string,
    entity   => scalar $c->stash->{collection}->execute(
      $c,
      for => create => with =>
        {%{$c->req->data}, __user => {obj => $c->user->obj},},
    )
  );
}

sub list : Chained(base) : PathPart('') Args(0) GET {
  my ($self, $c) = @_;
  $self->status_ok(
    $c,
    entity => $c->forward(
      _build_results => [$c->stash->{collection}->summary->with_geojson->as_hashref]
    )
  );

}

__PACKAGE__->meta->make_immutable;

1;
