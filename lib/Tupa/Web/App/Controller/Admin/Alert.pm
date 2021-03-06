package Tupa::Web::App::Controller::Admin::Alert;

use utf8;
use Moose;

use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/admin/base) PathPart(alert) CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection} = $c->model('DB::Alert');
}

sub object : Chained(base) : PathPart('') : CaptureArgs(Int) {
  my ($self, $c, $id) = @_;
  $c->stash->{object} = $c->stash->{collection}->find($id)
    or $c->detach('/error_404');
}

sub remove : Chained(object) PathPart('') Args(0) DELETE {
  my ($self, $c) = @_;
  $c->stash->{object}->alert_districts->delete;
  $c->stash->{object}->delete;
  $self->status_no_content($c);
}

sub create : Chained(base) PathPart('') Args(0) POST {
  my ($self, $c) = @_;

  my $alert = $c->stash->{collection}->execute($c,
    for => create => with =>
      {__user => {obj => $c->user->obj}, %{$c->req->data || {}}});

  $self->status_created(
    $c,
    location => $c->req->uri->as_string,
    entity   => $alert,
  );
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

__PACKAGE__->meta->make_immutable;

1;
