package AnyEvent::WebSocket::Connection;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use Protocol::WebSocket::Frame;
use Scalar::Util qw( weaken );

# ABSTRACT: WebSocket connection for AnyEvent
our $VERSION = '0.05'; # VERSION


has _stream => (
  is => 'ro',
  required => 1,
);

has _handle => (
  is       => 'ro',
  lazy     => 1,
  default  => sub { shift->_stream->handle },
  weak_ref => 1,
);

foreach my $type (qw( each next finish ))
{
  has "_${type}_cb" => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { [] },
  );
}

sub BUILD
{
  my $self = shift;
  weaken $self;
  my $finish = sub {
    $_->() for @{ $self->_finish_cb };
  };
  $self->_handle->on_error($finish);
  $self->_handle->on_eof($finish);

  my $frame = Protocol::WebSocket::Frame->new;
  
  $self->_stream->read_cb(sub {
    $frame->append($_[0]{rbuf});
    while(my $message = $frame->next)
    {
      $_->($message) for @{ $self->_next_cb };
      @{ $self->_next_cb } = ();
      $_->($message) for @{ $self->_each_cb };
    }
  });
}


sub send
{
  my $self = shift;
  $self->_handle->push_write(
    Protocol::WebSocket::Frame->new(shift)->to_bytes
  );
  $self;
}


sub on_each_message
{
  my($self, $cb) = @_;
  push @{ $self->_each_cb }, $cb;
  $self;
}


sub on_next_message
{
  my($self, $cb) = @_;
  push @{ $self->_next_cb }, $cb;
  $self;
}


sub on_finish
{
  my($self, $cb) = @_;
  push @{ $self->_finish_cb }, $cb;
  $self;
}

1;

__END__

=pod

=head1 NAME

AnyEvent::WebSocket::Connection - WebSocket connection for AnyEvent

=head1 VERSION

version 0.05

=head1 SYNOPSIS

 # send a message through the websocket...
 $connection->send('a message');
 
 # recieve message from the websocket...
 $connection->on_each_message(sub {
   my $message = shift;
   ...
 });
 
 # handle a closed connection...
 $connection->on_finish(sub {
   ...
 });

(See L<AnyEvent::WebSocket::Client> on how to create
a connection)

=head1 DESCRIPTION

This class represents a WebSocket connection with a remote
server (or in the future perhaps a client).

If the connection object falls out of scope then the connection
will be closed gracefully.

This class was created for a client to connect to a server 
via L<AnyEvent::WebSocket::Client>, but it may be useful to
reuse it for a server to interact with a client if a
C<AnyEvent::WebSocket::Server> is ever created (after the
handshake is complete, the client and server look pretty
much the same).

=head1 METHODS

=head2 $connection-E<gt>send($message)

Send a message to the other side.

=head2 $connection-E<gt>on_each_message($cb)

Register a callback to be called on each subsequent message received.
The message itself will be passed in as the only parameter to the
callback.

=head2 $connection-E<gt>on_next_message($cb)

Register a callback to be called the next message received.
The message itself will be passed in as the only parameter to the
callback.

=head2 $connection-E<gt>on_finish($cb)

Register a callback to be called when the connection is closed.

=head1 SEE ALSO

=over 4

=item *

L<AnyEvent::WebSocket::Client>

=item *

L<AnyEvent>

=back

=cut

=head1 AUTHOR

Graham Ollis <plicease@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut