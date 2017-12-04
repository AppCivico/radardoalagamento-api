use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET POST PUT DELETE);
use JSON qw(encode_json decode_json);
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
    diag('same phone -- ERROR');
    my ( $res, $ctx ) = ctx_request(
      POST '/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          token => {
            value => 'oh!token111',
          },
          user => {
            name                  => 'Foo',
            email                 => 'email11@email.com',
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
    ok( !$res->is_success, 'success' );
    is( $res->code, 400, '400 Bad request' );
    like( $res->content, qr/phone_number_already_exists/, 'message ok' );
    warn $res->as_string;
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

  {
    diag('no password - OK');
    my ( $res, $ctx ) = ctx_request(
      POST '/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          token => {
            value => 'no-password-user-token',
          },
          user => {
            name         => 'Foo',
            email        => 'email.nopassword@email.com',
            phone_number => '+5511899911121',
          },
        }
      )
    );
    ok( $res->is_success, 'success' );
    is( $res->code, 201, '201 created' );

  }

  {
    diag('create admin');
    my ( $res, $ctx ) = ctx_request(
      POST '/admin/signup',
      Content_Type => 'application/json',
      Content      => encode_json(
        {
          name                  => 'Foo',
          email                 => 'admin@email.com',
          password              => 'me_admin123',
          password_confirmation => 'me_admin123',
          phone_number          => '+5512899911111',
        }
      )
    );

    ok( $res->is_success, 'success' );
    is( $res->code, 201, '201 created' );

  }

  {
    my $session = __new_session();
    diag('update self');
    my $old_name = $session->user->name;
    my ( $res, $ctx ) = ctx_request(
      PUT '/me',
      Content_Type => 'application/json',
      'X-Api-Key'  => $session->api_key,
      Content      => encode_json(
        {
          name => ( my $new_name = 'Name ' . time ),
        }
      )
    );
    ok( $res->is_success, 'success' );
    is( $res->code, 202, '202 Accepted' );
    isnt( $new_name, $old_name, 'name changed' );
    is( decode_json( $res->content )->{name}, $new_name, 'name matches' );

  }

};

done_testing;
