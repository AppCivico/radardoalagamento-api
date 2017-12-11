package Tupa::Types;
use utf8;
use strict;
use warnings;

use MooseX::Types -declare => [qw(MobileNumber AlertLevel AppReportStatus)];

use MooseX::Types::Common::String qw(NonEmptySimpleStr NonEmptyStr);
use MooseX::Types::Moose qw(Str Int ArrayRef ScalarRef Num Maybe);
use Moose::Util::TypeConstraints;

my $is_international_mobile_number = sub {
  my $num = shift;
  return $num =~ /^\+\d{12,13}$/ ? 1 : 0 if $num =~ /\+55/;

  return $num =~ /^\+\d{10,16}$/ ? 1 : 0;
};

subtype MobileNumber, as Str, where {
  return 1 if $_ eq '+5599901010101';
  $is_international_mobile_number->($_);
};

enum AlertLevel,      [ 'attention', 'alert',   'emergency', 'overflow' ];
enum AppReportStatus, [ 'info',      'warning', 'error',     'debug' ];

1;

