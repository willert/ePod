#!/usr/bin/perl

use FindBin qw/$RealBin/;
use local::lib "$RealBin/../perl5";

use URI;
use URI::QueryParam;

$u = URI->new( $ENV{"QUERY_STRING"} || '?name=perldoc' );

print "Content-Type: text/html; charset=UTF-8\n\n";

push @ePod::local_libs, $u->query_param( 'locallib' );;
$ePod::module = $u->query_param( 'name' );

require "$RealBin/../bin/epod.pl";
