use utf8;
use strict;
use warnings;
use Test::More;
use lib "t/lib";
use Catalyst::Test 'Tupa::Web::App';
use HTTP::Request::Common qw(GET);
use JSON qw(encode_json);

use Tupa::Test;
use DDP;

binmode STDIN,  ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

my $schema = Tupa::Web::App->model('DB')->schema;

db_transaction {
  {
    my $session = __new_session($schema);

    diag('Listing sensors');
    {
      my ( $res, $ctx ) =

        ctx_request(
        GET '/sensor',
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key
        );

      ok( $res->is_success, 'Success' );
      is( $res->code, 200, '200 OK' );
    }

    ok(
      my $district = $schema->resultset('District')->search(
        undef,
        {
          columns => [
            grep { !/geom/ }
              $schema->resultset('District')->result_source->columns
          ],
          '+columns' => { 'center' => \'ST_PointOnSurface(geom)' },
          rows       => 1
        }
        )->next,
      'district ok'
    );
    ok(
      my $sensor = $schema->resultset('Sensor')->create(
        {
          name        => 'incidunt molestias facilis porro',
          description => 'excepturi reprehenderit placeat voluptatem',
          type        => 'assumenda saepe minima',
          source      => $schema->resultset('SensorSource')
            ->find_or_create( { name => 'Reprehenderit' } ),
          location => $district->get_column('center')
        }
      ),
      'center ok'
    );

    {
      my ( $res, $ctx ) =

        ctx_request(
        GET '/sensor/' . $sensor->id,
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key
        );

      ok( $res->is_success, 'Success' );
      is( $res->code, 200, '200 OK' );
      warn $res->as_string;
    }

    {
      my ( $res, $ctx ) =

        ctx_request(
        GET '/sensor/' . $sensor->id . '/sample',
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key
        );

      ok( $res->is_success, 'Success' );
      is( $res->code, 200, '200 OK' );
      warn $res->as_string;
    }

  }
};

done_testing;
