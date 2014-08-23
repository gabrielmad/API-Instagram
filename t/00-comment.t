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
            no_cache      => 1,
	})
);

my $data = join '', <DATA>;
my $json = decode_json $data;
$api->mock('_request', sub { $json });

my $media = $api->media(1);
isa_ok( $media, 'API::Instagram::Media' );

# First Object
my $get_comments = $media->get_comments;
is( ref $get_comments, 'ARRAY', 'media_get_comments' );

my $comment = $get_comments->[0];
isa_ok( $comment, 'API::Instagram::Media::Comment' );
is( $comment->id, 420, 'comment_id' );
is( $comment->text, 'Really amazing photo!', 'comment_text' );

my $from = $comment->from;
isa_ok( $from, 'API::Instagram::User' );
is( $from->full_name, 'Snoop Dogg', 'comment_from' );

my $time = $comment->created_time;
isa_ok( $time, 'Time::Moment' );
is( $time->year, 2010, 'comment_created_time' );


__DATA__
{
    "meta": {
        "code": 200
    },
    "data": [
        {
            "created_time": "1280780324",
            "text": "Really amazing photo!",
            "from": {
                "username": "snoopdogg",
                "profile_picture": "http://images.instagram.com/profiles/profile_16_75sq_1305612434.jpg",
                "id": "1574083",
                "full_name": "Snoop Dogg"
            },
            "id": "420"
        }
    ]
}