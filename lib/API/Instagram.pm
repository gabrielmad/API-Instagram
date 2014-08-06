=head1 NAME

API::Instagram - OO Interface to Instagram REST API

=for HTML <a href="https://travis-ci.org/gabrielmad/API-Instagram"><img src="https://travis-ci.org/gabrielmad/API-Instagram.svg?branch=build%2Fmaster"></a>

=head1 VERSION

version 0.002

=cut

package API::Instagram;
use Moo;

use Carp;
use strict;
use warnings;

use URI;
use JSON;
use LWP::UserAgent;
# use LWP::Protocol::Net::Curl;

use API::Instagram::User;
use API::Instagram::Location;
use API::Instagram::Tag;
use API::Instagram::Media;
use API::Instagram::Media::Comment;


# https://instagram.com/api/v1/direct_share/pending/
# https://instagram.com/api/v1/direct_share/inbox/


has client_id         => ( is => 'ro', required => 1 );
has client_secret     => ( is => 'ro', required => 1 );
has redirect_uri      => ( is => 'ro', required => 1 );
has scope             => ( is => 'ro', default => sub { 'basic' } );
has response_type     => ( is => 'ro', default => sub { 'code'  } );
has grant_type        => ( is => 'ro', default => sub { 'authorization_code' } );
has code              => ( is => 'rw', isa => sub { confess "Code not provided"        unless $_[0] } );
has access_token      => ( is => 'rw', isa => sub { confess "No access token provided" unless $_[0] } );
has no_cache          => ( is => 'rw', default => 0 );

has _ua               => ( is => 'ro', default => sub { LWP::UserAgent->new() } );
has _obj_cache        => ( is => 'ro', default => sub { { users => {}, medias => {}, locations => {}, tags => {} } } );
has _endpoint_url     => ( is => 'ro', default => sub { 'https://api.instagram.com/v1'                 } );
has _authorize_url    => ( is => 'ro', default => sub { 'https://api.instagram.com/oauth/authorize'    } );
has _access_token_url => ( is => 'ro', default => sub { 'https://api.instagram.com/oauth/access_token' } );


=head1 SYNOPSIS

	use API::Instagram;

	my $instagram = API::Instagram->new({
			client_id   	=> $client_id,
			client_secret	=> $client_secret,
			redirect_uri	=> 'http://localhost',
	});

	# Authenticated user feed
	my $my_user = $instagram->user;
	my $feed    = $my_user->feed( count => 5 );

	for my $media ( @$feed ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s at %s (%d likes)\n\n", $media->user->username, $media->created_time, $media->likes;

	}


=head1 DESCRIPTION

This module implements an OO interface to Instagram REST API.


=head2 Authentication

Instagram API uses the OAuth2 for authentication, requering a client_id and
client_secret. See L<http://instagr.am/developer/register/> for details.

=head3 Authorize

Get the AUTH URL to authenticate.

	use API::Instagram;

	my $instagram = API::Instagram->new({
			client_id		=> 'xxxxxxxxxx',
			client_secret	=> 'xxxxxxxxxx',
			redirect_uri	=> 'http://localhost',
			scope           => 'basic',
			response_type   => 'code',
			granty_type     => 'authorization_code',
	});

	my $auth_url = $instagram->get_auth_url;
	print $auth_url;


=head3 Authenticate

After authorization, Instagram will redirected the user to the url in
C<redirect_uri> with a code as an URL query parameter. This code is needed
to obtain an acess token.

	$instagram->set_code( $code );
	my $access_token = $instagram->get_access_token;

=head3 Request

With the access token its possible to request Instagram API using the
authenticated user credentials.

	$instagram->access_token( $access_token );
	my $me = $instagram->get_user;
	print $me->full_name;


=head1 METHODS

=head2 new

	my $instagram = API::Instagram->new({
			client_id   	=> $client_id,
			client_secret	=> $client_secret,
			redirect_uri	=> 'http://localhost',
			scope           => 'basic',
			response_type   => 'code',
			granty_type     => 'authorization_code',
			no_cache        => 1,
	});

Returns an L<API::Instagram> object.

Set C<client_id>, C<client_secret> and C<redirect_uri> with the ones registered
to your application. See L<http://instagram.com/developer/clients/manage/>.

C<scope> is the scope of access. See L<http://instagram.com/developer/authentication/#scope>.

C<response_code> and C<granty_type> do no vary. See L<http://instagram.com/developer/authentication/>.

By default, L<API::Instagram> caches created objects to avoid duplications. You can disable
this feature setting a true value to C<no_chace> parameter.

=head2 get_auth_url

Returns an Instagram authorization URL.

	my $auth_url = $instagram->get_auth_url;
	print $auth_url;

=cut
sub get_auth_url { 
	my $self = shift;

	carp "User already authorized with code: " . $self->code if $self->code;

	my @auth_fields = qw(client_id redirect_uri response_type scope);
	for ( @auth_fields ) {
		confess "ERROR: $_ required for generating authorization URL" unless defined $self->$_;
	}

	my $uri = URI->new( $self->_authorize_url );
	$uri->query_form( map { $_ => $self->$_ } @auth_fields );
	$uri->as_string();
}


=head2 get_access_token

	my $access_token = $instagram->get_access_token;

	or

	my ( $access_token, $auth_user ) = $instagram->get_access_token;

Returns the access token string if the context is looking for a scalar, or an
array containing the access token string and the authenticated user
L<API::Instagram::User> object if looking a list value.

=cut
sub get_access_token {
	my $self = shift;

	my @access_token_fields = qw(client_id redirect_uri grant_type client_secret code);
	for ( @access_token_fields ) {
		confess "ERROR: $_ required for generating access token." unless defined $self->$_;
	}

	my $data = { map { $_ => $self->$_ } @access_token_fields };
	my $json = from_json $self->_ua  ->post( $self->_access_token_url, $data )->content;

	my $meta = $json->{meta};
	confess "ERROR $meta->{error_type}: $meta->{error_message}" if $meta->{code} ne '200';

	wantarray ? ( $json->{access_token}, $self->user( $json->{user} ) ) : $json->{access_token};
}


=head2 media

	my $media = $instagram->media( $media_id );
	say $media->type;

Get information about a media object. Returns an L<API::Instagram::Media> object.

=cut
sub media { shift->_get_obj( 'media', '/medias', 'medias', 'id', shift ) }


=head2 user

	my $me = $instagram->user; # Authenticated user
	say $me->username;

	my $user = $instagram->user( $user_id );
	say $user->full_name;

Get information about user. Returns an L<API::Instagram::User> object.

=cut
sub user { shift->_get_obj( 'user', '/users', 'users', 'id', shift || 'self' ) }


=head2 location

	my $location = $instagram->location( $location_id );
	say $location->name;

Get information about a location. Returns an L<API::Instagram::Location> object.

=cut
sub location { shift->_get_obj( 'location', '/locations', 'locations', 'id', shift ) }


=head2 tag

	my $tag = $instagram->tag('perl');
	say $tag->media_count;

Get information about a tag. Returns an L<API::Instagram::Tag> object.

=cut
sub tag { shift->_get_obj( 'tag', '/tags', 'tags', 'name', shift ) }



sub _get_obj {
	my ( $self, $obj, $url, $cache, $key, $data, $opts ) = @_;

	my $id = ref $data eq 'HASH' ? $data->{$key} : $data;
	return if ref $id || !$id;

	my $method = "_create_${obj}_object";
	$data      = ref $data eq 'HASH' ? $data : $self->_request( "$url/$id" )->{data};

	$self->_cache($cache)->{$id} //= $self->$method( $data );

	delete $self->_cache($cache)->{$id} if $self->no_cache;

	$self->_cache($cache)->{$id};
}

sub _create_media_object {
	my $self = shift;
	my $obj  = shift;
	$obj->{_instagram} = $self;
	API::Instagram::Media->new( $obj );
}

sub _create_user_object {
	my $self = shift;
	my $obj  = shift;
	$obj->{_instagram} = $self;
	API::Instagram::User->new( $obj );
}

sub _create_location_object {
	my $self = shift;
	my $obj  = shift;
	$obj->{_instagram} = $self;
	API::Instagram::Location->new( $obj );
}

sub _create_tag_object {
	my $self = shift;
	my $obj  = shift;
	$obj->{_instagram} = $self;
	API::Instagram::Tag->new( $obj );
}

sub _create_comment_object {
	my $self = shift;
	my $obj  = shift;
	$obj->{_instagram} = $self;
	API::Instagram::Media::Comment->new( $obj );
}

sub _recent_medias {
	my ($self, $url, %opts) = @_;
	$opts{count} //= 33;
	[ map { $self->media($_) } $self->_get_list( %opts, url => $url ) ]
}

sub _get_list {
	my $self = shift;
	my %opts = @_;

	my $url      = delete $opts{url} || return [];
	my $count    = $opts{count} // 999_999_999;
	$count       = 999_999_999 if $count < 0;
	$opts{count} = $count;

	my $request = $self->_request( $url, \%opts );
	my $data    = $request->{data};

	while ( my $pagination = $request->{pagination} ){

		last if     @$data >= $count;
		last unless $pagination->{next_url};

		$request = $self->_request( $pagination->{next_url}, \%opts, { pagination => 1 } );
		push @$data, @{$request->{data}};
	}

	return @$data;
}

sub _request {
	my ( $self, $url, $params, $opts ) = @_;

	confess "A valid access_token is required" unless defined $self->access_token;

	unless ( $opts->{pagination} ){

		$url =~ s|^/||;
		$params->{access_token} = $self->access_token;

		my $uri = URI->new( $self->_endpoint_url );
		$uri->path_segments( $uri->path_segments, split '/', $url );
		$uri->query_form($params);
	    $url = $uri->as_string;
	}

	my $res  = decode_json $self->_ua  ->get( $url )->decoded_content;
	my $meta = $res->{meta};
	carp "ERROR $meta->{error_type}: $meta->{error_message}" if $meta->{code} ne '200';

	$res;
}

sub _cache {
	my ( $self, $cache ) = @_;
	$self->_obj_cache->{$cache};
}

sub _delete_cache {
	my ( $self, $cache, $id) = @_;
	delete $self->_obj_cache->{$cache}->{$id};
}

1;

=head1 BUGS

Please tell me bugs if you find bug.

C<< <gabriel.vieira at gmail.com> >>

L<http://github.com/gabrielmad/API-Instagram>


=head1 SEE ALSO

=over

=item *

L<WebService::Instagram>

=back

=head1 AUTHOR

Gabriel Vieira C<< <gabriel.vieira at gmail.com> >>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2014, Gabriel Vieira C<< <gabriel.vieira at gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
