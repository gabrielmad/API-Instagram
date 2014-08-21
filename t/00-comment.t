# #!/usr/bin/env perl

# use strict;
# use warnings;
# use Test::MockObject::Extends; 

# use JSON;
# use API::Instagram;
# use Test::More tests => 6;

# my $api = Test::MockObject::Extends->new(
# 	API::Instagram->new({
# 			client_id     => '123',
# 			client_secret => '456',
# 			redirect_uri  => 'http://localhost',
# 	})
# );

# my $data = decode_json join '', <DATA>;
# $api->mock('_request', sub { $data });
# $api->mock('_get_list', sub { [] });

# my $comment = $api->location('1');
# isa_ok( $comment, 'API::Instagram::Location' );
# is( $comment->id, 1, 'location_id' );
# is( $comment->name, 'Dogpatch Labs', 'location_name' );
# is( $comment->latitude, 37.782, 'location_latitude' );
# is( $comment->longitude, -122.387, 'location_longitude' );
# is( ref $comment->recent_medias, 'ARRAY', 'location_recent_medias' );

# has id           => ( is => 'ro', required => 1 );
# has from         => ( is => 'ro', required => 1, coerce => \&_coerce_from );
# has text         => ( is => 'ro', required => 1 );
# has created_time => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

# __DATA__
# {
#     "meta": {
#         "code": 200
#     },
#     "data": [
#         {
#             "created_time": "1280780324",
#             "text": "Really amazing photo!",
#             "from": {
#                 "username": "snoopdogg",
#                 "profile_picture": "http://images.instagram.com/profiles/profile_16_75sq_1305612434.jpg",
#                 "id": "1574083",
#                 "full_name": "Snoop Dogg"
#             },
#             "id": "420"
#         },
#     ]
# }