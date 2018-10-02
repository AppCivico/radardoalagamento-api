use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET POST);
use JSON qw(encode_json decode_json);
use DateTime;
use Tupa::Test;
use DDP;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $schema = Tupa::Web::App->model('DB')->schema;

db_transaction {
  my $session = __new_session($schema);

  $session->user->update({push_token => 'abc' . rand()});


  {
    diag('create report');
    my ($res, $ctx) =

      ctx_request(
      POST '/report',
      Content => encode_json(
        {
          description => 'foobar',
          level       => 'overflow',
          lat         => -23.5665139290104,
          lng         => -46.6667556012718,
          reported_ts => DateTime->now->iso8601
        }
      ),
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok($res->is_success, 'Success');
    is($res->code, 201, '201 Created');
  }

  {
    diag('list reports');
    my ($res, $ctx) = ctx_request(
      GET '/report',
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
    );
    ok($res->is_success, 'Success');
  }


  die 'rollback';


};

done_testing;
