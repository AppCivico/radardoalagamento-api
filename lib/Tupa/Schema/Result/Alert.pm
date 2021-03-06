use utf8;

package Tupa::Schema::Result::Alert;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Tupa::Schema::Result::Alert

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<alert>

=cut

__PACKAGE__->table("alert");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'alert_id_seq'

=head2 sensor_sample_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 level

  data_type: 'text'
  is_nullable: 0

=head2 pushed_to_users

  data_type: 'boolean'
  default_value: false
  is_nullable: 1

=head2 reporter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 report_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "alert_id_seq",
  },
  "sensor_sample_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 1},
  "description",
  {data_type => "text", is_nullable => 1},
  "level",
  {data_type => "text", is_nullable => 0},
  "pushed_to_users",
  {data_type => "boolean", default_value => \"false", is_nullable => 1},
  "reporter_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => {default_value => \"now()"},
  },
  "report_id",
  {data_type => "integer", is_foreign_key => 1, is_nullable => 1},
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 alert_districts

Type: has_many

Related object: L<Tupa::Schema::Result::AlertDistrict>

=cut

__PACKAGE__->has_many(
  "alert_districts", "Tupa::Schema::Result::AlertDistrict",
  {"foreign.alert_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

=head2 report

Type: belongs_to

Related object: L<Tupa::Schema::Result::Report>

=cut

__PACKAGE__->belongs_to(
  "report",
  "Tupa::Schema::Result::Report",
  {id => "report_id"},
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 reporter

Type: belongs_to

Related object: L<Tupa::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "reporter", "Tupa::Schema::Result::User",
  {id            => "reporter_id"},
  {is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION"},
);

=head2 sensor_sample

Type: belongs_to

Related object: L<Tupa::Schema::Result::SensorSample>

=cut

__PACKAGE__->belongs_to(
  "sensor_sample",
  "Tupa::Schema::Result::SensorSample",
  {id => "sensor_sample_id"},
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07047 @ 2018-07-03 10:09:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hDt1H8582KBiv+yQ5VQx+g

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->many_to_many(districts => 'alert_districts' => 'district');

use HTTP::Tiny;
use JSON qw(encode_json);
use List::MoreUtils qw(natatime);
sub TO_JSON { +{shift->get_columns} }
use feature 'state';

sub affected_users_keys {
  my ($self) = @_;

  return $self->alert_districts->related_resultset('district')
    ->related_resultset('user_districts')->related_resultset('user')
    ->get_column('push_token')->all
    if $self->districts->count;

  return $self->sensor_sample->sensor->districts->related_resultset(
    'user_districts')->related_resultset('user')->get_column('push_token')->all
    if $self->sensor_sample_id;

}

sub notify {
  my $self = shift;

  return if $ENV{HARNESS_ACTIVE} || ($0 =~ /forkprove/);

  state $http = HTTP::Tiny->new(timeout => 5);

  my $rest_api_key = $ENV{ONESIGNAL_REST_APY_KEY};
  my $app_id       = $ENV{ONESIGNAL_APP_ID};
  my @all_keys     = grep {defined} $self->affected_users_keys;
  my $it           = natatime 2000, @all_keys;
  while (my @keys = $it->()) {
    my $res = $http->post(
      'https://onesignal.com/api/v1/notifications',
      {
        content => encode_json(
          {
            app_id   => $app_id,
            contents => {pt => $self->description},
            headings {pt => 'Alerta de algamento'},
            include_player_ids => \@keys,
          }
        ),
        headers => {
          'Content-Type' => 'application/json; charset=utf-8',
          Authorization  => "Basic $rest_api_key"
        }
      }
    );

    if (!$res->{success}) {
      warn 'Failed: ' . $res->{content};
    }
    else {
      warn 'OK => ' . $res->{content};
    }

  }

}

__PACKAGE__->meta->make_immutable;
1;

