#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 4;

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

my $tag = $api->tag('nofilter');
isa_ok( $tag, 'API::Instagram::Tag' );
is( $tag->name, 'nofilter', 'tag_name' );
is( $tag->media_count, 472, 'tag_media_count' );
is( ref $tag->recent_medias, 'ARRAY', 'tag_recent_medias' );


__DATA__
{
    "data": {
        "media_count": 472,
        "name": "nofilter"
    }
}