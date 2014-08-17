package API::Instagram::Media;

# ABSTRACT: Instagram Media Object

use Moo;
use Time::Moment;

has _instagram     => ( is => 'ro' );
has id             => ( is => 'ro' );
has type           => ( is => 'ro' );
has user           => ( is => 'ro' );
has link           => ( is => 'ro' );
has filter         => ( is => 'ro' );
has tags           => ( is => 'ro', lazy => 1, builder => 1 );
has location       => ( is => 'ro' );
has images         => ( is => 'ro' );
has videos         => ( is => 'ro' );
has users_in_photo => ( is => 'ro' );
has caption        => ( is => 'ro', coerce => sub { $_[0]->{text}  } );
has likes          => ( is => 'ro', coerce => sub { $_[0]->{count} } );
has comments       => ( is => 'ro', coerce => sub { $_[0]->{count} } );
has created_time   => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

sub BUILD {
	my $self = shift;
	my $instagram           = $self->_instagram;
	$self->{user}           = $instagram->user( $self->{user} );
	$self->{location}       = $instagram->location( $self->{location} );
	$self->{users_in_photo} = [
		map {
			{
				user     => $instagram->user( $_->{user} ),
				position => $_->{position},
			}
		} @{$self->{users_in_photo}}
	];
}

sub _build_tags {
	my $self = shift;
	[ map { $self->_instagram->tag($_) } @{$self->{tags}} ]
}

sub get_likes {
	my $self = shift;
	my %opts = @_;
	my $url  = "/media/" . $self->id . "/likes";
	my $instagram = $self->_instagram;
	[ map { $instagram->user($_) } $instagram->_get_list( %opts, url => $url ) ]
}


sub get_comments {
	my $self = shift;
	my %opts = @_;
	my $url  = "/media/" . $self->id . "/comments";
	my $instagram = $self->_instagram;
	[ map { $instagram->_create_comment_object($_) } $instagram->_get_list( %opts, url => $url ) ]
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Media - Instagram Media Object

=for Pod::Coverage BUILD

=head1 VERSION

version 0.007

=head1 SYNOPSIS

	my $media = $instagram->media(3);

	printf "Caption: %s\n", $media->caption;
	printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	my $location = $media->location;
	printf "Media Location: %s (%f,%f)", $location->name, $location->latitude, $location->longitude;

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/media/>.

=head1 ATTRIBUTES

=head2 id

Returns media id.

=head2 type

Returns media type.

=head2 user

Returns the L<API::Instagram::User> object of the user who posted the media.

=head2 link

Returns media shortlink.

=head2 filter

Returns media filter.

=head2 tags

Returns a list L<API::Instagram::Tag> objects of media tags.

=head2 location

Returns media L<API::Instagram::Location> object.

=head2 images

	my $thumbnail = $media->images->{thumbnail};
	printf "URL: %s (%d x %d)" $thumbnail->{url}, $thumbnail->{width}, $thumbnail->{height};

Returns media images options and details.

=head2 videos

	my $standart = $media->videos->{standart_resolution};
	printf "URL: %s (%d x %d)" $standart->{url}, $standart->{width}, $standart->{height};

Returns media videos options and details, when video type.

=head2 users_in_photo

	for my $each ( @{ $media->users_in_photo } ) {

		my $user     = $each->{user};
		my $position = $each->{position};

		printf "%s is at %f, %f\n", $user->username, $position->{x}, $position->{y};

	}

Returns a list of L<API::Instagram::User> objects of users tagged in the media with their coordinates.

=head2 caption

Returns media caption text.

=head2 likes

Returns media total likes.

=head2 comments

Returns media total comments.

=head2 created_time

Returns the media date in a L<Time::Moment> object.

=head1 METHODS

=head2 get_likes

	my @likers = $media->get_likes( count => 5 );

Returns a list of L<API::Instagram::User> objects of users who liked the media.

Accepts C<count>.

=head2 get_comments

	my @comments = $media->get_comments( count => 5 );

Returns a list of L<API::Instagram::Media::Comment> objects of the media.

Accepts C<count>.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
