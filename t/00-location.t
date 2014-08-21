#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 9;

my $api = Test::MockObject::Extends->new(
	API::Instagram->new({
			client_id     => '123',
			client_secret => '456',
			redirect_uri  => 'http://localhost',
	})
);

my $data = join '', <DATA>;
my $json = decode_json $data;
$api->mock('_request', sub { $json });
$api->mock('_get_list', sub { [] });

my $location = $api->location('1');
isa_ok( $location, 'API::Instagram::Location' );
is( $location->id, 1, 'location_id' );
is( $location->name, 'Dogpatch Labs', 'location_name' );
is( $location->latitude, 37.782, 'location_latitude' );
is( $location->longitude, -122.387, 'location_longitude' );
is( ref $location->recent_medias, 'ARRAY', 'location_recent_medias' );

# Second Object
$json = decode_json $data;
delete $location->{id};

my $location2 = $api->location( $json->{data} );
isa_ok( $location2, 'API::Instagram::Location' );
is( $location2->id, undef, 'location2_undef_id' );
is( ref $location2->recent_medias, 'ARRAY', 'location2_recent_medias' );

__DATA__
{
    "data": {
        "id": "1",
        "name": "Dogpatch Labs",
        "latitude": 37.782,
        "longitude": -122.387
    }
}