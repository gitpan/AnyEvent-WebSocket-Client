
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "WebSocket client for AnyEvent",
  "dist_author" => [
    "Graham Ollis <plicease\@cpan.org>"
  ],
  "dist_name" => "AnyEvent-WebSocket-Client",
  "dist_version" => "0.08",
  "license" => "perl",
  "module_name" => "AnyEvent::WebSocket::Client",
  "recommends" => {
    "EV" => 0,
    "PerlX::Maybe::XS" => "0.003"
  },
  "recursive_test_files" => 1,
  "requires" => {
    "AnyEvent" => 0,
    "Moo" => 0,
    "PerlX::Maybe" => "0.003",
    "Protocol::WebSocket" => "0.12",
    "URI" => 0,
    "URI::ws" => 0,
    "perl" => "v5.10.0"
  },
  "script_files" => [],
  "test_requires" => {
    "Test::More" => 0
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
