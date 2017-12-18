package MyApp::Schema::Role::Paging;

use Moose::Role;
use MooseX::Types::Moose qw(Int);

sub with_paging {
  my ($self, %args) = @_;
  my $rs = $self;
  $rs
    = $rs->__page($args{page}
      && is_Int($args{page})
      && $args{page} > 0 ? $args{page} : 1);
  $rs
    = $rs->__rows($args{rows}
      && is_Int($args{rows})
      && $args{rows} > 0 ? $args{rows} : 20);
  $rs = $rs->__order_by($args{order_by})
    if exists $args{order_by}->{desc} || exists $args{order_by}->{asc};

  return $rs;
}

sub __page {
  shift->search_rs(undef, {page => shift});
}

sub __rows {
  shift->search_rs(undef, {rows => shift});
}

sub __order_by {
  my ($self, $order_by) = @_;
  $self->search_rs(
    undef,
    {
      order_by => {
        ((-desc => $order_by->{desc}) x !!$order_by->{desc}),
        ((-asc  => $order_by->{asc}) x !!$order_by->{asc})
      }
    }
  );
}

1;
