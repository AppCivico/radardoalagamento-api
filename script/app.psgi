use strict;
use warnings;

use Plack::Builder;
use Plack::App::File;
use Tupa::Web::App;
use IO::Handle;

autoflush STDOUT 1;
autoflush STDERR 1;

my $app = Tupa::Web::App->psgi_app(@_);

builder {
  enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
  "Plack::Middleware::ReverseProxy";

  enable q{CrossOrigin},
    origins => q{*},
    methods => [qw(GET POST OPTIONS PUT HEAD DELETE PATCH)];

  enable "Plack::Middleware::XSendfile", variation => 'X-Accel-Redirect';

  mount '/' => $app;
};
