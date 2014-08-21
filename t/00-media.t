#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 18;

my $api = Test::MockObject::Extends->new(
	API::Instagram->new({
			client_id     => '123',
			client_secret => '456',
			redirect_uri  => 'http://localhost',
	})
);

$api->mock('_request', sub { decode_json join '', <DATA> });
$api->mock('_get_list', sub { [] });

my $media = $api->media(3);
isa_ok( $media,               'API::Instagram::Media');
isa_ok( $media->user,         'API::Instagram::User' );
isa_ok( $media->created_time, 'Time::Moment'         );

is( $media->id,                 3,                        'media_id'             );
is( $media->type,               'video',                  'media_video'          );
is( $media->likes,              1,                        'media_likes'          );
is( $media->comments,           2,                        'media_comments'       );
is( $media->user->username,     'kevin',                  'media_user'           );
is( $media->created_time->year, 2010,                     'media_created_time'   );
is( $media->users_in_photo,     undef,                    'media_users_in_photo' );
is( $media->caption,            undef,                    'media_caption'        );
is( $media->location,           undef,                    'media_location'       );
is( $media->link,               'http://instagr.am/p/D/', 'media_link'           );
is( ref $media->images,         'HASH',                   'media_images'         );
is( ref $media->videos,         'HASH',                   'media_videos'         );
is( ref $media->tags,           'ARRAY',                  'media_videos'         );
is( ref $media->get_likes,      'ARRAY',                  'media_get_likes'      );
is( ref $media->get_comments,   'ARRAY',                  'media_get_comments'   );

__DATA__
{
    "data": {
        "type": "video",
        "videos": {
            "low_resolution": {
                "url": "http://distilleryvesper9-13.ak.instagram.com/090d06dad9cd11e2aa0912313817975d_102.mp4",
                "width": 480,
                "height": 480
            },
            "standard_resolution": {
                "url": "http://distilleryvesper9-13.ak.instagram.com/090d06dad9cd11e2aa0912313817975d_101.mp4",
                "width": 640,
                "height": 640
            }
        },
        "users_in_photo": null,
        "filter": "Vesper",
        "tags": [],
        "comments": {
            "data": [{
                "created_time": "1279332030",
                "text": "Love the sign here",
                "from": {
                    "username": "mikeyk",
                    "full_name": "Mikey Krieger",
                    "id": "4",
                    "profile_picture": "http://distillery.s3.amazonaws.com/profiles/profile_1242695_75sq_1293915800.jpg"
                },
                "id": "8"
            }, {
                "created_time": "1279341004",
                "text": "Chilako taco",
                "from": {
                    "username": "kevin",
                    "full_name": "Kevin S",
                    "id": "3",
                    "profile_picture": "..."
                },
                "id": "3"
            }],
            "count": 2
        },
        "caption": null,
        "likes": {
            "count": 1,
            "data": [{
                "username": "mikeyk",
                "full_name": "Mikeyk",
                "id": "4",
                "profile_picture": "..."
            }]
        },
        "link": "http://instagr.am/p/D/",
        "user": {
            "username": "kevin",
            "full_name": "Kevin S",
            "profile_picture": "...",
            "bio": "...",
            "website": "...",
            "id": "3"
        },
        "created_time": "1279340983",
        "images": {
            "low_resolution": {
                "url": "http://distilleryimage2.ak.instagram.com/11f75f1cd9cc11e2a0fd22000aa8039a_6.jpg",
                "width": 306,
                "height": 306
            },
            "thumbnail": {
                "url": "http://distilleryimage2.ak.instagram.com/11f75f1cd9cc11e2a0fd22000aa8039a_5.jpg",
                "width": 150,
                "height": 150
            },
            "standard_resolution": {
                "url": "http://distilleryimage2.ak.instagram.com/11f75f1cd9cc11e2a0fd22000aa8039a_7.jpg",
                "width": 612,
                "height": 612
            }
        },
        "id": "3",
        "location": null
    }
}