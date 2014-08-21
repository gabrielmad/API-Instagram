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
is( $api->client_id, 123, 'client_id' );
is( $api->client_secret, 456, 'client_secret' );
is( $api->redirect_uri, 'http://localhost', 'redirect_uri' );
is( $api->no_cache, 1, 'no_cache' );