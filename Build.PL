
# This file was automatically generated by Dist::Zilla::Plugin::ModuleBuild v5.020.
use strict;
use warnings;

use Module::Build 0.28;
use lib qw{inc}; use My::ModuleBuild;

my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.28"
  },
  "configure_requires" => {
    "Module::Build" => "0.28"
  },
  "dist_abstract" => "WebSocket client for AnyEvent",
  "dist_author" => [
    "Graham Ollis <plicease\@cpan.org>"
  ],
  "dist_name" => "AnyEvent-WebSocket-Client",
  "dist_version" => "0.28",
  "license" => "perl",
  "module_name" => "AnyEvent::WebSocket::Client",
  "recommends" => {
    "EV" => 0,
    "IO::Socket::SSL" => 0,
    "Math::Random::Secure" => 0,
    "Net::SSLeay" => 0,
    "PerlX::Maybe::XS" => 0
  },
  "recursive_test_files" => 1,
  "requires" => {
    "AE" => 0,
    "AnyEvent" => 0,
    "Carp" => 0,
    "Encode" => 0,
    "Moo" => "1.001000",
    "PerlX::Maybe" => "0.003",
    "Protocol::WebSocket" => "0.15",
    "URI" => 0,
    "URI::ws" => 0,
    "perl" => "5.008"
  },
  "script_files" => [],
  "test_requires" => {
    "FindBin" => 0,
    "Protocol::WebSocket" => "0.15",
    "Test::More" => "0.94"
  }
);


my %fallback_build_requires = (
  "FindBin" => 0,
  "Module::Build" => "0.28",
  "Protocol::WebSocket" => "0.15",
  "Test::More" => "0.94"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = My::ModuleBuild->new(%module_build_args);

$build->create_build_script;
