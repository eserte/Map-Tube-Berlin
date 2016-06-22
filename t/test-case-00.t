#!perl

use strict;
use utf8;
use Test::More 'no_plan';
use Map::Tube::Berlin;

sub fix_whitespace ($);

my $missing_station_rx      = qr{(?:\QERROR: Either FROM/TO node is undefined\E|\QMap::Tube::get_shortest_route(): ERROR: Missing Station Name.\E)};
my $invalid_from_station_rx = qr/(?:\QMap::Tube::get_shortest_route(): ERROR: Received invalid FROM node 'XYZ'\E|\QMap::Tube::get_node_by_name(): ERROR: Invalid station name.\E|\QMap::Tube::get_node_by_name(): ERROR: Invalid Station Name\E)/;
my $invalid_to_station_rx   = qr/(?:\QMap::Tube::get_shortest_route(): ERROR: Received invalid TO node 'XYZ'\E|\QMap::Tube::get_node_by_name(): ERROR: Invalid station name.\E|\QMap::Tube::get_node_by_name(): ERROR: Invalid Station Name\E)/;

my $map = Map::Tube::Berlin->new();
isa_ok $map, 'Map::Tube::Berlin';

eval { $map->get_shortest_route(); };
like($@, $missing_station_rx);

eval { $map->get_shortest_route('Friedrichstr.'); };
like($@, $missing_station_rx);

eval { $map->get_shortest_route('XYZ', 'Friedrichstr.'); };
like($@, $invalid_from_station_rx);

eval { $map->get_shortest_route('Friedrichstr.', 'XYZ'); };
like($@, $invalid_to_station_rx);

{
    my $ret = $map->get_shortest_route('Friedrichstr.', 'Alexanderplatz');
    isa_ok $ret, 'Map::Tube::Route';
    is fix_whitespace($ret), 'Friedrichstr. (S1,S2,S25,S3,S5,S7,S75,U6), Hackescher Markt (S3,S5,S7,S75), Alexanderplatz (S3,S5,S7,S75,U2,U5,U8)', 'Friedrichstr. - Alex';
}

{
    my $ret = $map->get_shortest_route('Schönhauser Allee', 'Gesundbrunnen');
    isa_ok $ret, 'Map::Tube::Route';
    is fix_whitespace($ret), 'Schönhauser Allee (S41/S42,S8,S85,S9,U2), Gesundbrunnen (S1,S2,S25,S41/S42,U8)', 'special case: Ringbahn';
}

{
    my $ret = $map->get_shortest_route('platz der luftbrücke', 'möckernbrücke');
    isa_ok $ret, 'Map::Tube::Route';
    is fix_whitespace($ret), 'Platz der Luftbrücke (U6), Mehringdamm (U6,U7), Möckernbrücke (U1,U7)', ' case-insensitive search';
}

SKIP: {
    skip "other_link feature requires Map::Tube 2.89", 2
	if $Map::Tube::VERSION < 2.89;

    my $ret = $map->get_shortest_route('Adenauerplatz', 'Savignyplatz');
    isa_ok $ret, 'Map::Tube::Route';
    if ($Map::Tube::VERSION >= 3.13) {
	is fix_whitespace($ret), 'Adenauerplatz (U7), Wilmersdorfer Str. (Street,U7), Charlottenburg (S3,S5,S7,S75, Street), Savignyplatz (S3,S5,S7,S75)', 'with other_link';
    } else {
	is fix_whitespace($ret), 'Adenauerplatz (U7), Wilmersdorfer Str. (U7), Charlottenburg (S3,S5,S7,S75), Savignyplatz (S3,S5,S7,S75)', 'with other_link';
    }
}

# Normalize stringification: earlier Map::Tube versions (approx. 2.70
# and earlier) had no whitespace in line number lists.
sub fix_whitespace ($) {
    my $ret = shift;
    $ret =~ s{,\s+(?=[US]\d)}{,}g;
    $ret;
}
