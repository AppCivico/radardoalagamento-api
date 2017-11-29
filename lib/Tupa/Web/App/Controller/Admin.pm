package Tupa::Web::App::Controller::Admin;

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Tupa::Web::App::Controller'; }

sub base : Chained(/logged_in) PathPart(admin) CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->detach('/error_403') unless $c->check_user_roles(qw/admin/);
}

__PACKAGE__->meta->make_immutable;

1;
