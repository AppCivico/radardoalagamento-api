package Tupa::Web::App::Controller;

use utf8;
use Moose;
use namespace::autoclean;
use Data::Dumper qw(Dumper);
use Text::CSV::Flatten;
BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
  default => 'application/json',
  'map'   => {'application/json' => 'JSON::XS',},
);

sub end : Private {
  my ($self, $c) = @_;
  my $code = $c->res->status;

  my $err;
  if (scalar @{$c->error}) {
    $code = 500;
    $c->stash->{errors} = $c->error;
    my ($top, @others) = @{$c->error};

    if (ref $top eq 'HASH' and scalar @{$top}{qw(type msg_id)}) {
      $c->stash->{rest} = [$c->build_api_error(%$top)];
      $code = 400;
      $c->log->error(Dumper($c->req->data));
    }

    $err = '';
    foreach my $error ($top, @others) {
      $err .= Dumper $error;
    }
    ($err = substr $err, 0, 5000 . "\n"),
      $err
      =~ s|^(\s+)| my $x = length($1); $x /= 6; $x = $x ? $x : 0; $x = ' ' x $x; $x |emg
      if $err =~ /InvalidBaseTypeGivenToCreateParameterizedTypeConstraint/;
    $c->log->error($err)
      unless $code == 400 && ($ENV{HARNESS_ACTIVE} || $0 =~ /forkprove/);
    $c->clear_errors;

    #    $c->detach('/error_500');
  }

  if ($code =~ /^5/ && !$c->res->body && !$c->stash->{rest}) {
    $code = 500;

    # eval {
    #   my $hostname = `hostname`;
    #   chomp($hostname);
    #   $err = substr( $err, 0, 350 ) . ':koko:' . substr( $err, -250 )
    #     if length $err > 603;
    #   $c->slack_notify( sprintf( "[$hostname] Erro 500 $err ", $hostname ),
    #     channel => '#api-error' );
    # };
    $c->stash->{rest} = {
      type           => 'internal_error',
      message        => 'Internal error',
      system_message => '(╯°□°）╯︵ ┻━┻',
      short_message  => '¯\_(ツ)_/¯'
    };

  }

  $c->res->status($code);

  $c->forward('serialize');
}

sub _build_results : Private {
  my ($self, $c, $rs) = @_;
  my %results = ();
  my %args = (%{$c->req->params || {}}, %{+eval { $c->req->data } || {}});

  $rs = $rs->filter(%args) if $rs->can('filter');

  if ($args{no_paging}) {
    $results{results} = [$rs->all];
    return \%results;
  }

  my $content_type
    = $args{content_type}
    || $c->req->header('Accept')
    || $c->req->content_type;

  if ($content_type =~ /\/csv$/i) {
    $c->res->content_type('text/csv');
    $c->res->header('Content-disposition' => 'filename="extract.csv"');
    $c->res->status(200);
    $c->res->body(
      Text::CSV::Flatten->new('.<index>.*', data => [$rs->all])->csv());
    $c->detach;
  }

  $rs = $rs->with_paging(%args) if $rs->can('with_paging');

  if (my $pager = $rs->pager) {
    $results{total_entries}    = $pager->total_entries;
    $results{next_page}        = $pager->next_page;
    $results{previous_page}    = $pager->previous_page;
    $results{entries_per_page} = $pager->entries_per_page;
  }
  $results{results} = [$rs->all];
  return \%results;
}

sub serialize : ActionClass('Serialize') {
}

1;

