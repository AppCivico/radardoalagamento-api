package Tupa::Web::App::Controller::Me;

use utf8;
use Moose;
use MooseX::Types::Moose qw(Int);
use namespace::autoclean -except => 'Int';

BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/logged_in) PathPart(me) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{me} = $c->user->obj;
}

sub update : Chained(base) PathPart('') Args(0) PUT {
  my ( $self, $c ) = @_;
  my $data = $c->req->data || {};
  my $user = delete $data->{user} || {};
  
  $self->status_accepted( $c,
    entity =>
      scalar $c->{stash}->{me}
      ->execute( $c, for => update => with => {%$user, %$data} ) );
}

__PACKAGE__->meta->make_immutable;

1;
