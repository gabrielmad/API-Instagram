package API::Instagram::User;

# ABSTRACT: Instagram User Object

use Moo;
use Carp;

has _instagram     => ( is => 'ro' );
has id             => ( is => 'ro' );
has username       => ( is => 'ro' );
has full_name      => ( is => 'ro' );
has bio            => ( is => 'ro' );
has website        => ( is => 'ro' );
has profile_picute => ( is => 'ro', lazy => 1, builder => 1 );
has media          => ( is => 'ro', lazy => 1, builder => 1 );
has follows        => ( is => 'ro', lazy => 1, builder => 1 );
has followed_by    => ( is => 'ro', lazy => 1, builder => 1 );

sub BUILD {
	my $self   = shift;
	my $params = shift;
	if ( $params->{counts} ){
		$self->{media}       = $params->{counts}{media};
		$self->{follows}     = $params->{counts}{follows};
		$self->{followed_by} = $params->{counts}{followed_by};
	}
};



sub feed {
	my $self = shift;
	my @list = $self->_self_requests( 'feed', '/users/self/feed', @_ );
	[ map { $self->_instagram->media($_) } @list ]
}


sub liked_media {
	my $self = shift;
	my @list = $self->_self_requests( 'liked-media', '/users/self/media/liked', @_ );
	[ map { $self->_instagram->media($_) } @list ]
}


sub requested_by {
	my $self = shift;
	my @list = $self->_self_requests( 'requested-by', '/users/self/requested-by', @_ );
	[ map { $self->_instagram->user($_) } @list ]
}


sub get_follows {
	shift->_get_relashions( @_, relationship => 'follows' );
}


sub get_followers {
	shift->_get_relashions( @_, relationship => 'followed-by' );
}


sub recent_medias {
	my $self = shift;
	my $url  = "/users/" . $self->id . "/media/recent";
	$self->_instagram->_recent_medias( $url, @_ );
}





sub _get_relashions {
	my $self = shift;
	my %opts = @_;
	my $url  = "/users/" . $self->id . "/" . $opts{relationship};
	my $instagram = $self->_instagram;
	[ map { $instagram->user($_) } $instagram->_get_list( %opts, url => $url ) ]
}

sub _self_requests {
	my ($self, $type, $url, %opts) = @_;

	if ( $self->id ne $self->_instagram->user->id ){
		carp "The $type is only available for the authenticated user";
		return [];
	}

	$self->_instagram->_get_list( %opts, url => $url )
}

sub _build_profile_picute { shift->_reload->{profile_picute} }

sub _build_media { shift->_reload->{media} }

sub _build_follows { shift->_reload->{follows} }

sub _build_followed_by { shift->_reload->{followed_by} }

sub _reload {
	my $instagram = $_[0]->_instagram;
	$instagram->_delete_cache( 'users', $_[0]->id );
	$_[0] = $instagram->user( $_[0]->id );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::User - Instagram User Object

=head1 VERSION

version 0.005.1

=head1 SYNOPSIS

	my $me    = $instagram->user;
	my $other = $instagra->user(12345);

	printf "My username is %s and I follow %d other users.\n", $me->username, $me->follows;
	printf "The other user full name is %s", $other->full_name;

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/users/> and L<http://instagram.com/developer/endpoints/relationships/>.

=head1 ATTRIBUTES

=head2 id

Returns user id.

=head2 username

Returns user username.

=head2 full_name

Returns user full name.

=head2 bio

Returns user biography text.

=head2 website

Returns user website.

=head2 profile_picute

Returns user profile picture url.

=head2 media

Returns user total media.

=head2 follows

Returns user total follows.

=head2 followed_by

Returns user total followers.

=head1 METHODS

=head2 feed

	my $medias = $user->feed( count => 5 );
	print $_->caption . $/ for @$medias;

Returns a list of L<API::Instagram::Media> objects of the authenticated user feed.

Accepts C<count>, C<min_id> and C<max_id> as parameters.

=head2 liked_media

	my $medias = $user->liked_media( count => 5 );
	print $_->caption . $/ for @$medias;

Returns a list of L<API::Instagram::Media> objects of medias liked by the authenticated user.

Accepts C<count> and C<max_like_id> as parameters.

=head2 requested_by

	my $requested_by = $user->get_requested_by( count => 5 );
	print $_->username . $/ for @$requested_by;

Returns a list of L<API::Instagram::User> objects of users who requested this user's permission to follow.

Accepts C<count> as parameter.

=head2 get_follows

	my $follows = $user->get_follows( count => 5 );
	print $_->username . $/ for @$follows;

Returns a list of L<API::Instagram::User> objects of users this user follows.

Accepts C<count> as parameter.

=head2 get_followers

	my $followers = $user->get_followers( count => 5 );
	print $_->username . $/ for @$followers;

Returns a list of L<API::Instagram::User> objects of users this user is followed by.

Accepts C<count> as parameter.

=head2 recent_medias

	my $medias = $user->recent_medias( count => 5 );
	print $_->caption . $/ for @$medias;

Returns a list of L<API::Instagram::Media> objects of user's recent medias.

Accepts C<count>, C<min_timestamp>, C<min_id>, C<max_id> and C<max_timestamp> as parameters.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
