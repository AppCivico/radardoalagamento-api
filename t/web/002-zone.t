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

    diag('Listing zones');
    {
      my ($res, $ctx) =

        ctx_request(
        my $req = GET '/zone',
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key
        );

      ok($res->is_success, 'Success');
      is($res->code, 200, '200 OK');
    }

    ok(
      my $zone = $schema->resultset('Zone')->search(
        undef,
        {
          columns => [
            grep { !/geom/ } $schema->resultset('Zone')->result_source->columns
          ],
          '+columns' => {'center' => \'ST_PointOnSurface(geom)'},
          rows       => 1
        }
      )->next,
      'zone ok'
    );
    ok(
      my $sensor = $schema->resultset('Sensor')->create(
        {
          name        => 'incidunt molestias facilis porro',
          description => 'excepturi reprehenderit placeat voluptatem',
          sensor_type => 'assumenda saepe minima',
          source      => $schema->resultset('SensorSource')
            ->find_or_create({name => 'Reprehenderit'}),
          location => $zone->get_column('center')
        }
      ),
      'center ok'
    );

    {
      my ($res, $ctx) =

        ctx_request(
        GET '/zone/' . $zone->id,
        'X-Api-Key'  => $session->api_key,
        Content_Type => 'application/json'
        );

      ok($res->is_success, 'Success');
      is($res->code, 200, '200 OK');
    }

    {
      my ($res, $ctx) =

        ctx_request(
        GET '/zone/' . $zone->id . '/sensor',
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key,
        );

      ok($res->is_success, 'Success');
      is($res->code, 200, '200 OK');
    }


    {
      my ($res, $ctx) =

        ctx_request(
        GET '/zone?name=' . $zone->name,
        Content_Type => 'application/json',
        'X-Api-Key'  => $session->api_key,
        );

      ok($res->is_success, 'Success');
      is($res->code, 200, '200 OK');

      my $name = $zone->name;
      ok(my $json = decode_json($res->content), 'body ok');
      is(scalar @{$json->{results}}, 1, 'count ok');
      like($json->{results}->[0]->{name}, qr/\Q$name\E/, 'name matches');

    }


  }
};

done_testing;
