#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
use FindBin::libs;
use Tupa::Schema;
use Tupa::Mailer;
use Cwd 'abs_path';
use MIME::Lite;
use Encode;
($ENV{TUPA_CONFIG_FILE} && -r $ENV{TUPA_CONFIG_FILE})
  or die 'missing TUPA_CONFIG_FILE';

my $config    = do '' . abs_path($ENV{TUPA_CONFIG_FILE});
my $db_config = $config->{model}->{DB}->{connect_info};
my $schema    = Tupa::Schema->connect($db_config->{dsn}, $db_config->{user},
  $db_config->{password}, $db_config);

my $dbh = $schema->storage->dbh;


my $mailer = Tupa::Mailer->new;
$dbh->do("LISTEN mailer");
LISTENLOOP: {

  while (my $notify = $dbh->pg_notifies) {
    my ($name, $pid, $payload) = @$notify;

    my $email = MIME::Lite->new(
      Subject =>
        Encode::encode('MIME-Header', '[Radar Do Alagamento] Erro reportado'),
      Type => 'text/html; charset=UTF-8',
      Data => "<p> $payload </p>"
    );

    eval {
      $mailer->send($email->as_string,
        qw(gabriel.andrade@eokoe.com lais@eokoe.com gian.vizzotto@eokoe.com));
    };
    warn $@ if $@;
  }
  $dbh->ping() or die qq{Ping failed!};
  sleep(5);
  redo;
}
