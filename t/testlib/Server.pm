package testlib::Server;

use strict;
use warnings;
use v5.10;
use URI;
use Test::More;
use AnyEvent::Handle;
use AnyEvent::Socket qw( tcp_server);
use Protocol::WebSocket::Handshake::Server;
use Protocol::WebSocket::Frame;

my $timeout;

sub set_timeout
{
  return if defined $timeout;
  $timeout = AnyEvent->timer( after => 5, cb => sub {
    diag "timeout!";
    exit 2;
  });
}

sub start_server
{
  my $class = shift;
  my $opt = { @_ };
  $opt->{handshake} //= sub {};
  my $server_cv = AnyEvent->condvar;

  tcp_server undef, undef, sub {
    my $handshake = Protocol::WebSocket::Handshake::Server->new;
    my $frame     = Protocol::WebSocket::Frame->new;
  
    my $hdl = AnyEvent::Handle->new( fh => shift );
  
    $hdl->on_read(
      sub {
        my $chunk = $_[0]{rbuf};
        $_[0]{rbuf} = '';

        unless($handshake->is_done) {
          $handshake->parse($chunk);
          if($handshake->is_done)
          {
            $hdl->push_write($handshake->to_string);
            $opt->{handshake}->(handshake => $handshake, hdl => $hdl);
          }
          return;
        }
      
        $frame->append($chunk);
      
        while(defined(my $message = $frame->next))
        {
          $opt->{message}->(frame => $frame, message => $message, hdl => $hdl);
        }
      }
    );
  }, sub {
    my($fh, $host, $port) = @_;
    $server_cv->send($port);
  };

  my $port = $server_cv->recv;
  
  my $uri = URI->new('ws://127.0.0.1/echo');
  $uri->port($port);
  note "$uri";
  $uri;
}

sub start_echo
{
  shift->start_server(message => sub {
    my $opt = { @_ };
    
    return if !$opt->{frame}->is_text && !$opt->{frame}->is_binary;

    $opt->{hdl}->push_write($opt->{frame}->new($opt->{message})->to_bytes);
        
    if($opt->{message} eq 'quit')
    {
      $opt->{hdl}->push_write($opt->{frame}->new(type => 'close')->to_bytes);
      $opt->{hdl}->push_shutdown;
    }
  });
}

1;
