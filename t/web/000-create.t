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

my ( $res, $ctx ) = ctx_request( GET '/' );
ok( $res->is_success );

db_transaction {

  {
    diag('invalid');
    my ( $res, $ctx ) = ctx_request(
      POST '/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          name     => 'Foo',
          email    => 'email@email.com',
          password => '1234',
        }
      )
    );
    ok( !$res->is_success, 'error' );
    is( $res->code, 400, '400 error' );
  }

  {
    diag('valid');
    my ( $res, $ctx ) = ctx_request(
      POST '/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          token => {
            value => 'oh!token',
          },
          user => {
            name                  => 'Foo',
            email                 => 'email@email.com',
            password              => '1234567890',
            password_confirmation => '1234567890',
            phone_number          => '+5511999911111',
            districts             => [
              $schema->resultset('District')->search_rs( undef, { rows => 4 } )
                ->get_column('id')->all
            ]
          },
        }
      )
    );
    ok( $res->is_success, 'success' );
    is( $res->code, 201, '201 created' );
  }

  {
    diag('valid');
    my ( $res, $ctx ) = ctx_request(
      POST '/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          token => {
            value => 'oh!token2',
          },
          user => {
            name                  => 'Foo',
            email                 => 'email2@email.com',
            password              => '1234567890',
            password_confirmation => '1234567890',
            phone_number          => '+5511899911111',
            districts             => []
          },
        }
      )
    );
    ok( $res->is_success, 'success' );
    is( $res->code, 201, '201 created' );

  }

};

done_testing;
