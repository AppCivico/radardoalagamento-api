package Tupa::Web::App::Controller::Alert;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/logged_in) PathPart(alert) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{collection} =
    $c->user->obj->user_districts->related_resultset('district')
    ->related_resultset('sensors')->related_resultset('samples')
    ->related_resultset('alerts');
}

sub list : Chained(base) PathPart('') Args(0) GET {
  my ( $self, $c ) = @_;

  $self->status_ok( $c,
    entity =>
      { results => [ $c->stash->{collection}->summary->as_hashref->all ] } );
}

__PACKAGE__->meta->make_immutable;

1;
