package Tupa::Web::App::Controller::Root;

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Tupa::Web::App::Controller'; }

__PACKAGE__->config( namespace => '' );

# sub base : Chained('/') PathPart('') CaptureArgs(0) { }

# sub root : Chained('base') PathPart('') Args(0) {
#   my ( $self, $c ) = @_;
#   $c->response->status(200);
#   $c->res->body('HEY');

# }

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;

  # Hello World
  $c->response->body( $c->welcome_message );
}

sub default : Path {
  my ( $self, $c ) = @_;
  $c->response->body('Page not found');
  $c->response->status(404);
}
sub end : ActionClass('RenderView') { }

__PACKAGE__->meta->make_immutable;
1;
