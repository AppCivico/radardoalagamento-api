package Tupa::Web::App::Controller::Login;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/) PathPart(login) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{collection} = $c->model('DB::User');
}

sub login : Chained(base) PathPart('') Args(0) POST {
  my ( $self, $c ) = @_;

  my $session = $c->stash->{collection}
    ->execute( $c, for => login => with => $c->req->data );
  $self->status_ok( $c, entity => { api_key => $session->api_key } );
}

__PACKAGE__->meta->make_immutable;

1;
