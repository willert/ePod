#!/usr/bin/env perl

use 5.010;

use strict;
use warnings;

use English;
use File::Spec;

our $log;

BEGIN {
  my $login = getlogin || getpwuid( $< ) || "kilroy";
  my $logfile = File::Spec->catfile(
    File::Spec->tmpdir, sprintf( 'epod_%s.log', $login )
  );

  open( $log, '>>', $logfile );

  $SIG{__DIE__} = sub{
    say $log @_;
    die @_;
  };

  $SIG{__WARN__} = sub{
    say $log @_;
  };
}

package ePod;
use strict;
use warnings;

use base 'Pod::Simple::HTML';

use 5.010;

our @include;
our $module;

our $DEBUG = 2;

# needs to return a URL string such
# - http://some.other.com/page.html
# - #anchor_in_the_same_file
# - /internal/ref.html

sub do_pod_link {
  # My::Pod object and Pod::Simple::PullParserStartToken object
  my ($self, $link) = @_;

  if ( $DEBUG > 1 ) {
    say $log 'Tag: ' , $link->tagname;          # will be L for links
    say $log 'To: ' , $link->attr('to') // 'N/A';       #
    say $log 'Type: ' , $link->attr('type');     # will be 'pod' always
    say $log 'Sec: ' , $link->attr('section') // 'N/A';
    say $log '';
  }

  return $self->SUPER::do_pod_link( $link )
    unless $link->tagname eq 'L' and $link->attr('type') eq 'pod';

  my $pd_link;
  if ( $link->attr('to')) {

    $pd_link = sprintf( 'perldoc:module?name=%s', $link->attr('to') );
    $pd_link .= "&include=$_" for @include;
    $pd_link .= sprintf( '#%s', $link->attr('section'))
      if $link->attr('section');
  } else {
    $pd_link = sprintf( '#%s', map{s/\s/_/g;$_} $link->attr('section'))
  }

  say $log 'Generated link: '. $pd_link if $DEBUG;

  return $pd_link;
}

package main;

use Path::Class qw(dir file);
use FindBin qw/$Bin/;
use lib "$Bin/../lib";

BEGIN {
  no strict 'refs';
  *CORE::GLOBAL::exit = sub{};
  # $ENV{'PERLDOCDEBUG'} = 3
}

use Pod::Perldoc qw//;
use Capture::Tiny qw/:all/;

my $doc = $module || $ARGV[0];

printf $log "Scanning for %s\n", $doc;

my ( $pod, $err ) = capture {
  local @INC = @INC;
  push @INC, $_ for @include;

  eval{ Pod::Perldoc->run( args => [ '-oPod', $doc ] ) }
};

die "Can't find docs for: $doc\nError was:$err\n" unless $pod;

my $p = ePod->new;
$p->output_string( \ my $html );
$p->index( 1 );
$p->parse_string_document( $pod );

print "<!DOCTYPE html>\n\n$html\n\n";
