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
  my $session = __new_session($schema);

  {
    diag('create report');
    my ($res, $ctx) =

      ctx_request(
      POST '/app-report',
      Content      => encode_json({payload => 'Foo',}),
      Content_Type => 'application/json',
      );
    ok($res->is_success, 'OK');
    is($res->code, 204, '204 - No Content');
  }

  {
    diag('create report - error');
    my ($res, $ctx) =

      ctx_request(
      POST '/app-report',
      Content      => encode_json({payload => '',}),
      Content_Type => 'application/json',
      );
    ok(!$res->is_success, 'Error');
    is($res->code, 400, '400 - Bad request');
    like($res->content, qr/payload.*?invalid/, 'message ok');
  }


  {
    diag('list reports');
    my ($res, $ctx) =

      ctx_request(
      GET '/app-report',
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok($res->is_success, 'OK');
    is($res->code, 200, '200 ok');
  }

  ok($session->user->add_to_roles({name => 'admin'}), 'user is now an admin');

  {
    diag('list reports - admin');
    my ($res, $ctx) =

      ctx_request(
      GET '/admin/app-report',
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key
      );
    ok($res->is_success, 'OK');
    is($res->code, 200, '200 Success');

    my ($report) = decode_json($res->content)->{results}->[0];

    {
      diag('mark report as read - admin');
      my ($res, $ctx) =

        ctx_request(
        PUT '/admin/app-report/' . $report->{id},
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key
      );

      ok($res->is_success, 'OK');
      
      is($res->code, 202, '202 Accepted');

    }
  }


};

done_testing;
