#!/usr/bin/perl

use FindBin qw/$RealBin/;
use local::lib "$RealBin/../perl5";

use URI;
use URI::QueryParam;

$u = URI->new( $ENV{"QUERY_STRING"} || '?name=perldoc' );

print "HTTP/1.1 200 OK\n";
print "Content-Type: text/html; charset=UTF-8\n";
print "Connection: close\n";

print "\n\n";

push @ePod::include, $u->query_param( 'include' )
  if $u->query_param( 'include' );

$ePod::module = $u->query_param( 'name' );

require "$RealBin/epod.pl";
exit 0;
