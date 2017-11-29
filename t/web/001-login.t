use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET POST PUT DELETE);
use JSON qw(encode_json);

use Tupa::Test;
use DDP;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $schema = Tupa::Web::App->model('DB')->schema;

db_transaction {

  {

    diag('Empty object on body request');
    my ( $res, $ctx ) = ctx_request(
      POST '/login',
      Content_Type => 'application/json',
      Content      => encode_json( {} )
   );
    ok( !$res->is_success, 'error' );
    is( $res->code, 400, '400 error' );
  }

  {

    diag('user does not exist');
    my ( $res, $ctx ) = ctx_request(
      POST '/login',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          email    => 'email@email.com',
          password => '1234'
        }
      )
    );
    ok( !$res->is_success, 'error' );
    is( $res->code, 400, '400 error' );
  }

  {
    diag('user exists');
    my $user =
      $schema->resultset('User')
      ->create(
      { name => 'Foo', password => '1234', email => 'email@email.com' } );

    my ( $res, $ctx ) = ctx_request(
      POST '/login',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          email    => 'email@email.com',
          password => '1234'
        }
      )
    );
    ok( $res->is_success, 'login ok' );
    is( $res->code, 200, '200 ok' );
  }
};

done_testing;
