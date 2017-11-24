package Tupa::Web::App::Controller::Signup;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/) PathPart(signup) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{collection} = $c->model('DB::User');
}

sub create : Chained(base) PathPart('') Args(0) POST {
  my ( $self, $c ) = @_;

  my $data = $c->req->data || {};
  my $user = $data->{user} || {};
  my $token   = $data->{token}->{value};
  my $session = $c->stash->{collection}
    ->execute( $c, for => create => with => { %$user, push_token => $token } );
  $self->status_created(
    $c,
    location => $c->uri_for('/me')->as_string,
    entity   => { api_key => $session->api_key }
  );
}

__PACKAGE__->meta->make_immutable;

1;
