#!/usr/bin/env perl

use strict;
use warnings;
use Test::MockObject::Extends; 

use JSON;
use API::Instagram;
use Test::More tests => 5;

my $api = API::Instagram->new({
			client_id     => '123',
			client_secret => '456',
			redirect_uri  => 'http://localhost',
            no_cache      => 1
});

isa_ok( $api, 'API::Instagram');
ok( $api->get_auth_url, 'get_auth_url' );

$api->code('789');

is( $api->code, 789, 'code' );
is( $api->access_token, undef, 'access_token' );
is( $api->user->username, undef, 'user' );