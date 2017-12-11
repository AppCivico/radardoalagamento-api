use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET POST);
use JSON qw(encode_json);
use DateTime;
use Tupa::Test;
use DDP;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $schema = Tupa::Web::App->model('DB')->schema;

db_transaction {
  my $session = __new_session($schema);

  {
    diag('create report');
    my ( $res, $ctx ) =

      ctx_request(
      POST '/app-report',
      Content => encode_json(
        {
          payload => 'Foo',
          status  => 'error',
        }
      ),
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok( $res->is_success, 'OK' );
    is( $res->code, 204, '204 - No Content' );
  }

  {
    diag('create report - error');
    my ( $res, $ctx ) =

      ctx_request(
      POST '/app-report',
      Content => encode_json(
        {
          payload => '',
          status  => 'info',
        }
      ),
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok( !$res->is_success, 'Error' );
    is( $res->code, 400, '400 - Bad request' );
    like( $res->content, qr/payload.*?invalid/, 'message ok' );
  }
  {
    diag('create report - error');
    my ( $res, $ctx ) =

      ctx_request(
      POST '/app-report',
      Content => encode_json(
        {
          payload => 'Foobar',
          status  => '',
        }
      ),
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok( !$res->is_success, 'Error' );
    is( $res->code, 400, '400 - Bad request' );
    like( $res->content, qr/status.*?invalid/, 'message ok' );
  }

  {
    diag('create report - error');
    my ( $res, $ctx ) =

      ctx_request(
      POST '/app-report',
      Content => encode_json(
        {
          payload => 'Foobar',
          status  => 'XXXXXX',
        }
      ),
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok( !$res->is_success, 'Error' );
    is( $res->code, 400, '400 - Bad request' );
    like( $res->content, qr/status.*?invalid/, 'message ok' );
  }

  {
    diag('list reports');
    my ( $res, $ctx ) =

      ctx_request(
      GET '/app-report',
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok( $res->is_success, 'OK' );
    is( $res->code, 200, '200 ok' );
  }

};

done_testing;
