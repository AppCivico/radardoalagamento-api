package Tupa::Web::App::Controller::Admin::AppReport;

use utf8;
use Moose;
use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/admin/base) PathPart('app-report') CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash->{collection} = $c->model('DB::AppReport');
}

sub object : Chained(base) : PathPart('') : CaptureArgs(Int) {
  my ($self, $c, $id) = @_;
  $c->stash->{object} = $c->stash->{collection}->find($id)
    or $c->detach('/error_404');
}

sub solve : Chained(object) : PathPart('') Args(0) PUT {
  my ($self, $c) = @_;
  $self->status_accepted($c,
    entity =>
      $c->stash->{object}->update({solved_at => \q{now()}})->discard_changes);
}

sub list : Chained(base) : PathPart('') Args(0) GET {
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
