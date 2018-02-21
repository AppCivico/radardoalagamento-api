package Tupa::Mailer;

use Moose;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use Try::Tiny;

my ($password, $username);

BEGIN {
  $username = $ENV{SENDGRID_USER} || 'bdatum';
  $password
    = $ENV{SENDGRID_PASSWORD} || 'foo';   # die 'ENV SENDGRID_PASSWORD MISSING';
}

has from => (is => 'ro', default => 'no-reply@radardoalagamento.org.br');
has transport => (is => 'ro', lazy_build => 1);

sub _build_transport {
  return Email::Sender::Transport::SMTP::TLS->new(
    helo     => "b-datum.com",
    host     => 'smtp.sendgrid.net',
    timeout  => 20,
    port     => 587,
    username => $username,
    password => $password
  );

}

sub send {
  my ($self, $email, @recipients) = @_;
  sendmail($email,
    {to => [@recipients], from => $self->from, transport => $self->transport});
}

1;
