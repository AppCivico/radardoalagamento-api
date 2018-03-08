#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
use FindBin::libs;
use Tupa::Schema;
use HTTP::Tiny;
use URI;
use Cwd 'abs_path';
use POSIX qw(strftime gmtime);
use DateTime;
use DateTimeX::Easy qw(parse);

($ENV{TUPA_CONFIG_FILE} && -r $ENV{TUPA_CONFIG_FILE})
  or die 'missing TUPA_CONFIG_FILE';

my $user = $ENV{SAISP_USER} or die 'Missing SAISP_USER env var';
my $pass = $ENV{SAISP_PASS} or die 'Missing SAISP_PASS env var';

my $config    = do '' . abs_path($ENV{TUPA_CONFIG_FILE});
my $db_config = $config->{model}->{DB}->{connect_info};
my $schema    = Tupa::Schema->connect($db_config->{dsn}, $db_config->{user},
  $db_config->{password}, $db_config);
my $base_uri
  = URI->new("https://$user:$pass\@www.saisp.br/geral/export_telem.jsp");

my @sensors = (
  {
    code        => 1000946,
    description => 'Córrego Itaim  - Rua Joaquim L. Veiga',
    location    => '-23.5732336,-46.7792928',
    types       => ['0 PLU(mm)', '1 FLU(m)'],
  },
  {
    code        => 1000947,
    description => 'Córrego Jaguaré - Rua Jorge Ward',
    location    => '-23.5680505,-46.7591848',
    types       => ['0 PLU(mm)', '1 FLU(m)'],
  },
  {
    code        => 1000948,
    description => 'FCTH - USP',
    location    => '-23.5591155,-46.6982622',
    types       => ['0 PLU(mm)'],
  },
  {
    code        => 1000950,
    description => 'Córrego Jaguaré - Escola Politécnica',
    location    => '-23.5570464,-46.7328786',
    types       => ['1 FLU(m)']
  },
  {
    code        => 686,
    description => 'Coopercotia',
    location    => '-23.5971586,-46.8001592',
    types       => ['0 PLU(mm)'],
  },
  {
    code        => 693,
    description => 'P1 - Parque Tizo',
    location    => '-23.6025189,-46.8174299',
    types       => ['1 FLU(m)'],
  },
  {code => 694, description => 'P2 - Nascentes',   types => ['1 FLU(m)'],},
  {code => 696, description => 'P4 - Água Podre', types => ['1 FLU(m)'],},
  {code => 697, description => 'P5 - Kenkiti',     types => ['1 FLU(m)'],},
  {code => 698, description => 'P6 - Sapê',       types => ['1 FLU(m)']},
  {code => 695, description => 'P3 - Jacarezinho', types => ['1 FLU(m)'],},
  {
    code        => 1000949,
    description => 'Precipitação Radar Bacia Jaguaré',
    types       => ['0 PLU Radar(mm)'],
  },
  {
    code        => 1000951,
    description => 'Precipitação Radar - P1 - Parque Tizo',
    types       => ['0 PLU Radar(mm)'],
  },
  {
    code        => 1000952,
    description => 'Precipitação Radar - P2 - Nascentes',
    types       => ['0 PLU Radar(mm)'],
  },
  {
    code        => 1000953,
    description => 'Precipitação Radar - P3 - Jacarezinho',
    types       => ['0 PLU Radar(mm)'],
  },
  {
    code        => 1000954,
    description => 'Precipitação Radar - P4 - Água Podre',
    types       => ['0 PLU Radar(mm)'],
  },
  {
    code        => 1000955,
    description => 'Precipitação Radar - P5 - Kentiki',
    types       => ['0 PLU Radar(mm)']
  },
  {
    code        => 1000956,
    description => 'Precipitação Radar - P6 - Sapê',
    types       => ['0 PLU Radar(mm)']
  }
);

my $http = HTTP::Tiny->new;
my $source
  = $schema->resultset('SensorSource')->find_or_create({name => 'SAISP'});
while (1) {

  foreach my $sensor_spec (@sensors) {

    #    ?cnt=1&posto_1=1000947&instrum_1=0&dt_1=201701011201
    foreach my $type_str (@{$sensor_spec->{types} || []}) {
      my ($index, $type) = $type_str =~ /^(\d+)\s+(.*?)$/;

      $sensor_spec->{location} = \(
        sprintf(
          qq{'SRID=4326;POINT(%s %s)::geography'},
          reverse split /,/,
          $sensor_spec->{location}
        )
      ) if $sensor_spec->{location};

      my $sensor = $source->sensors->find_or_create(
        {
          name        => $sensor_spec->{code},
          description => $sensor_spec->{description},
          type        => $type_str,
          location    => $sensor_spec->{location},
        }
      );

      my $last_sample = $sensor->samples->last->next;
      my $last_ts;

      $last_ts
        = $last_sample->event_ts->set_time_zone('America/Sao_Paulo')
        ->format_cldr('YMMddHHmm')
        if $last_sample;

      my $uri = $base_uri->clone;
      $uri->query_form(
        cnt       => 1,
        posto_1   => $sensor_spec->{code},
        instrum_1 => $index,
        dt_1      => (
          $last_ts || DateTime->from_epoch(
            epoch     => time,
            time_zone => 'America/Sao_Paulo'
          )->format_cldr('YMMddHHmm')
        )
      );
      my $res = $http->get($uri->as_string);
      my $sample;
      ($sample = build_sample($_)) && $sensor->samples->find_or_create($sample)
        for grep {
        my (undef, undef, $ts) = split /,/, $_;
        !$last_ts || ($ts > $last_ts)
        } grep {defined} split /\s+/, $res->{content};
    }
  }
  sleep(10 * 60);    # 10 minutos
}

sub build_sample {
  my $line = shift;
  my (undef, undef, $ts, $value) = split /,/, $line;
  $ts =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5/;
  return unless $ts;

  return {
    value    => $value,
    event_ts => parse($ts, time_zone => 'America/Sao_Paulo')->iso8601
  };
}
