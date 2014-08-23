#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 36;

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
$api->mock('_get_list', sub { [] });

# First Object
my $media = $api->media(3);
isa_ok( $media, 'API::Instagram::Media' );
is( $media->id,               3,                        'media_id'             );
is( $media->type,             'video',                  'media_video'          );
is( $media->filter,           'Vesper',                 'media_filter'         );
is( $media->likes,            1,                        'media_likes'          );
is( $media->comments,         2,                        'media_comments'       );
is( $media->users_in_photo,   undef,                    'media_users_in_photo' );
is( $media->caption,          undef,                    'media_caption'        );
is( $media->link,             'http://instagr.am/p/D/', 'media_link'           );
is( ref $media->images,       'HASH',                   'media_images'         );
is( ref $media->videos,       'HASH',                   'media_videos'         );
is( ref $media->last_likes,   'ARRAY',                  'media_last_likes'     );
is( ref $media->last_comments,'ARRAY',                  'media_last_comments'  );
is( ref $media->get_likes,    'ARRAY',                  'media_get_likes'      );
is( ref $media->get_comments, 'ARRAY',                  'media_get_comments'   );

my $user = $media->user;
isa_ok( $user, 'API::Instagram::User' );
is( $user->username, 'kevin', 'media_user' );

my $tags = $media->tags;
is( ref $tags, 'ARRAY', 'media_videos' );
isa_ok( $tags->[0], 'API::Instagram::Tag' );

my $location = $media->location;
isa_ok( $location, 'API::Instagram::Location');
is( $location->latitude, 0.2, 'media_location' );

isa_ok( $media->created_time, 'Time::Moment' );
is( $media->created_time->year, 2010, 'media_created_time' );

$json = decode_json $data;
is( $media->likes(1),    1, 'media_likes_after_clear_data'    );
is( $media->comments(1), 2, 'media_comments_after_clear_data' );

is( ref $media->last_likes(1),    'ARRAY', 'media_last_likes_clear_data'    );
is( ref $media->last_comments(1), 'ARRAY', 'media_last_comments_clear_data' );

# Second Object
$json = decode_json $data;
delete $json->{data}->{location};
undef  $json->{data}->{tags};
$json->{data}->{users_in_photo} = [
    {
        "user" => {
            "username" => "kevin",
            "full_name" => "Kevin S",
            "id" => "3",
            "profile_picture" => "..."
        },
        "position" => {
            "x" => 0.315,
            "y" => 0.9111
        }
    }
];

my $media2 = $api->media( $json->{data} );
isa_ok( $media2, 'API::Instagram::Media' );
is( $media2->location, undef, 'media2_location');
is( $media2->tags, undef, 'media2_tags');

my $uip = $media2->users_in_photo;
is( ref $uip, 'ARRAY', 'media2_users_in_photo' );

my $item = $uip->[0];
is( ref $item, 'HASH', 'media2_users_in_photo_content' );

my $item_user = $item->{user};
isa_ok( $item_user, 'API::Instagram::User' );
is( $item_user->username, 'kevin', 'media2_users_in_photo_content_user_username' );

my $item_pos = $item->{position};
is( ref $item_pos, 'HASH', 'media2_users_in_photo_content_position' );
is( $item_pos->{y}, 0.9111, 'media2_users_in_photo_content_position_y' );


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
        "tags": ["test"],
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
        "location": { "latitude":"0.2", "longitude":"0.3"}
    }
}