use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET POST PUT);
use JSON qw(encode_json);
use DateTime;
use Tupa::Test;
use DDP;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $schema = Tupa::Web::App->model('DB')->schema;

db_transaction {

  {
    my $event = {
          'lat' => 0,
          'lng' => 0,
          'atMin' => 0,
          'rhMax' => 0,
          'rhAvg' => 0,
          'atAvg' => 0,
          'timestamp' => time,
          'atMax' => 0,
          'sttName' => 'name',
          'sttId' => 'id',
          'rhMin' => 0
        };
    
    diag('create report');
    my ($res, $ctx) =

      ctx_request(
      POST '/sensor/pluvion',
      Content      => encode_json($event),
      Content_Type => 'application/json',
      );
    ok($res->is_success, 'OK');
    is($res->code, 201, '201 - Created');
  }


};

done_testing;
