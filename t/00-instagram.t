#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use Furl;
use Furl::Response;
use API::Instagram;
use Test::More tests => 11;

my $data = join '', <DATA>;
my $ua   = Test::MockObject::Extends->new( Furl->new() );
my $res  = Test::MockObject::Extends->new( Furl::Response->new( 1, 200, 'OK', {}, $data) );

$ua->mock('get',  sub { $res });
$ua->mock('post', sub { $res });

my $api = API::Instagram->new({
			client_id     => '123',
			client_secret => '456',
			redirect_uri  => 'http://localhost',
            no_cache      => 1,
            _ua           => $ua,
});


isa_ok( $api, 'API::Instagram');
ok( $api->get_auth_url, 'get_auth_url' );
is( $api->get_access_token, undef, 'get_access_token' );

$api->code('789');
is( $api->code, 789, 'code' );
is( $api->user->username, undef, 'user' );

my ( $access_token, $me ) = $api->get_access_token;
is( $access_token, 123456789, 'get_access_token' );

$api->access_token( $access_token );
is( $api->access_token, 123456789, 'get_access_token' );

isa_ok( $me, 'API::Instagram::User');
is( $me->username, "snoopdogg", 'auth_user' );

is( ref $api->_request('media'), 'HASH', '_request' );
is( ref $api->_get_list( count => 2 ), 'ARRAY', '_get_list' );

__DATA__
{
    "meta": {
        "code": 200
    },
    "pagination": {
        "next_url": "http://localhost"
    },
    "data":[1],
    "access_token": 123456789,
    "user": {
        "id": "1574083",
        "username": "snoopdogg",
        "full_name": "Snoop Dogg",
        "profile_picture": "http://distillery.s3.amazonaws.com/profiles/profile_1574083_75sq_1295469061.jpg",
        "bio": "This is my bio",
        "website": "http://snoopdogg.com",
        "counts": {
            "media": 1320,
            "follows": 420,
            "followed_by": 3410
        }
    }
}