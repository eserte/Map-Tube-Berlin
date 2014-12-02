package Map::Tube::Berlin;

$VERSION = '0.01';

=head1 NAME

Map::Tube::Berlin - Interface to the Berlin S- and U-Bahn Map.

=cut

use File::Share ':all';

use Moo;
use namespace::clean;

has xml => (is => 'ro', default => sub { return dist_file('Map-Tube-Berlin', 'berlin-map.xml') });

with 'Map::Tube';

=head1 DESCRIPTION

It currently provides functionality to find the shortest route between
the two given nodes. The map contains both U-Bahn and S-Bahn stations.

=head1 CONSTRUCTOR

    use Map::Tube::Berlin;
    my $tube = Map::Tube::Berlin->new;

=head1 METHODS

=head2 get_shortest_route()

This method expects two parameters START and END node name. Node name
is case insensitive. It returns back the node sequence from START to
END.

    use Map::Tube::Berlin;
    my $tube = Map::Tube::Berlin->new;

    my $route = $tube->get_shortest_route('Zoologischer Garten', 'Alexanderplatz');

    print "Route: $route\n";

=head1 AUTHOR

Slaven Rezic

=cut

1;
