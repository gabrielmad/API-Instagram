#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 6;

my $api = Test::MockObject::Extends->new(
	API::Instagram->new({
			client_id     => '123',
			client_secret => '456',
			redirect_uri  => 'http://localhost',
	})
);

my $data = decode_json join '', <DATA>;
$api->mock('_request', sub { $data });
$api->mock('_get_list', sub { [] });

my $location = $api->location('1');
isa_ok( $location, 'API::Instagram::Location' );
is( $location->id, 1, 'location_id' );
is( $location->name, 'Dogpatch Labs', 'location_name' );
is( $location->latitude, 37.782, 'location_latitude' );
is( $location->longitude, -122.387, 'location_longitude' );
is( ref $location->recent_medias, 'ARRAY', 'location_recent_medias' );

__DATA__
{
    "data": {
        "id": "1",
        "name": "Dogpatch Labs",
        "latitude": 37.782,
        "longitude": -122.387
    }
}