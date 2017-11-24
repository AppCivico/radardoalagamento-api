package Tupa::Web::App::Controller::Admin::Alert;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/admin/base) PathPart(alert) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{collection} = $c->model('DB::Alert');
}

sub create : Chained(base) PathPart('') Args(0) POST {
  my ( $self, $c ) = @_;

  my $alert = $c->stash->{collection}->execute( $c,
    for => create => with =>
      { __user => { obj => $c->user->obj }, %{ $c->req->data || {} } } );

  $self->status_created(
    $c,
    location => $c->req->uri->as_string,
    entity   => $alert,
  );
}

__PACKAGE__->meta->make_immutable;

1;
