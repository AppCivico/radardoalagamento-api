package Tupa::Web::App::Controller::Root;

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Tupa::Web::App::Controller'; }

__PACKAGE__->config( namespace => '' );

sub base : Chained('/') PathPart('') CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->stash->{maybe_api_key} =
       $c->req->param('api_key')
    || ( $c->req->headers->header('x-api-key') )
    || ( $c->req->data ? $c->req->data->{api_key} : undef );
}

sub logged_in : Chained(base) : PathPart('') : CaptureArgs(0) {
  my ( $self, $c ) = @_;
#  $c->forward('api_key_check');
}

sub api_key_check : Private {
  my ( $self, $c ) = @_;

  return $c->forward(
    'try_login',
    [
      on_missing_api_key => sub {
        $self->status_bad_request( $c, message => 'Missing api key' );
        $c->detach;
      },
      on_access_denied => sub {
        $self->status_forbidden( $c, message => "access denied", ), $c->detach;
      }
    ]
  );

}

sub try_login : Private {
  my ( $self, $c, %cbs ) = @_;

  $c->stash->{maybe_api_key} =
       $c->req->param('api_key')
    || ( $c->req->headers->header('x-api-key') )
    || ( $c->req->data ? $c->req->data->{api_key} : undef );

  if ( my $api_key = $c->stash->{maybe_api_key} ) {
    my $session = $c->model('DB::UserSession')->search(
      {
        api_key       => $api_key,
        'user.active' => 1,
        valid_until   => { '>=' => \'now()' },
      },
      { join => 'user' }
      )->next
      or ( $cbs{on_access_denied} || sub { } )->(), return 0;

    my $user = $c->find_user( { id => $session->user_id } )
      or ( $cbs{on_access_denied} || sub { } )->(), return 0;

    $c->set_authenticated($user);
    return 1;
  }
  else {
    ( $cbs{on_missing_api_key} || sub { } )->();
    return 0;
  }
}

# sub root : Chained('base') PathPart('') Args(0) {
#   my ( $self, $c ) = @_;
#   $c->response->status(200);
#   $c->res->body('HEY');
# }

sub index : Path : Args(0) {
  my ( $self, $c ) = @_;

  # Hello World
  $c->response->body('OK');
}

sub default : Path {
  my ( $self, $c ) = @_;
  $c->response->body('Page not found');
  $c->response->status(404);
}

sub error_404 : Private {
  my ( $self, $c ) = @_;
  $c->response->status(404);
  $c->res->body('');
}
sub end : ActionClass('RenderView') { }

__PACKAGE__->meta->make_immutable;
1;
