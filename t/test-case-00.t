#!perl

use strict;
use utf8;
use Test::More 'no_plan';
use Map::Tube::Berlin;

my $map = Map::Tube::Berlin->new();
isa_ok $map, 'Map::Tube::Berlin';

eval { $map->get_shortest_route(); };
like($@, qr/ERROR: Either FROM\/TO node is undefined/);

eval { $map->get_shortest_route('Friedrichstr.'); };
like($@, qr/ERROR: Either FROM\/TO node is undefined/);

eval { $map->get_shortest_route('XYZ', 'Friedrichstr.'); };
like($@, qr/\QMap::Tube::get_shortest_route(): ERROR: Received invalid FROM node 'XYZ'\E/);

eval { $map->get_shortest_route('Friedrichstr.', 'XYZ'); };
like($@, qr/\QMap::Tube::get_shortest_route(): ERROR: Received invalid TO node 'XYZ'\E/);

{
    my $ret = $map->get_shortest_route('Friedrichstr.', 'Alexanderplatz');
    isa_ok $ret, 'Map::Tube::Route';
    is $ret, 'Friedrichstr. (S1,S2,S25,S3,S5,S7,S75,U6), Hackescher Markt (S3,S5,S7,S75), Alexanderplatz (S3,S5,S7,S75,U2,U5,U8)', 'Friedrichstr. - Alex';
}

{
    my $ret = $map->get_shortest_route('Schönhauser Allee', 'Gesundbrunnen');
    isa_ok $ret, 'Map::Tube::Route';
    is $ret, 'Schönhauser Allee (S41/S42,S8,S85,S9,U2), Gesundbrunnen (S1,S2,S25,S41/S42,U8)', 'special case: Ringbahn';
}

{
    my $ret = $map->get_shortest_route('platz der luftbrücke', 'möckernbrücke');
    isa_ok $ret, 'Map::Tube::Route';
    is $ret, 'Platz der Luftbrücke (U6), Mehringdamm (U6,U7), Möckernbrücke (U1,U7)', ' case-insensitive search';
}
