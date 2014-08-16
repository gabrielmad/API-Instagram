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
has tags           => ( is => 'ro' );
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
	$self->{tags}           = [ map { $instagram->tag($_) } @{$self->{tags}} ];
	$self->{users_in_photo} = [
		map {
			{
				user     => $instagram->user( $_->{user} ),
				position => $_->{position},
			}
		} @{$self->{users_in_photo}}
	];
}

=head1 SYNOPSIS

	my $media = $instagram->media(3);

	printf "Caption: %s\n", $media->caption;
	printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	my $location = $media->location;
	printf "Media Location: %s (%f,%f)", $location->name, $location->latitude, $location->longitude;


=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/media/>.

=attr id

Returns media id.

=attr type

Returns media type.

=attr user

Returns the L<API::Instagram::User> object of the user who posted the media.

=attr link

Returns media shortlink.

=attr filter

Returns media filter.

=attr tags

Returns a list L<API::Instagram::Tag> objects of media tags.

=attr location

Returns media L<API::Instagram::Location> object.

=attr images

	my $thumbnail = $media->images->{thumbnail};
	printf "URL: %s (%d x %d)" $thumbnail->{url}, $thumbnail->{width}, $thumbnail->{height};

Returns media images options and details.

=attr videos

	my $standart = $media->videos->{standart_resolution};
	printf "URL: %s (%d x %d)" $standart->{url}, $standart->{width}, $standart->{height};

Returns media videos options and details, when video type.

=attr users_in_photo

	for my $each ( @{ $media->users_in_photo } ) {

		my $user     = $each->{user};
		my $position = $each->{position};

		printf "%s is at %f, %f\n", $user->username, $position->{x}, $position->{y};

	}

Returns a list of L<API::Instagram::User> objects of users tagged in the media with their coordinates.

=attr caption

Returns media caption text.

=attr likes

Returns media total likes.

=attr comments

Returns media total comments.

=attr created_time

Returns the media date in a L<Time::Moment> object.

=method get_likes

	my @likers = $media->get_likes( count => 5 );

Returns a list of L<API::Instagram::User> objects of users who liked the media.

Accepts C<count>.

=cut
sub get_likes {
	my $self = shift;
	my %opts = @_;
	my $url  = "/media/" . $self->id . "/likes";
	my $instagram = $self->_instagram;
	[ map { $instagram->user($_) } $instagram->_get_list( %opts, url => $url ) ]
}

=method get_comments

	my @comments = $media->get_comments( count => 5 );

Returns a list of L<API::Instagram::Media::Comment> objects of the media.

Accepts C<count>.

=cut

sub get_comments {
	my $self = shift;
	my %opts = @_;
	my $url  = "/media/" . $self->id . "/comments";
	my $instagram = $self->_instagram;
	[ map { $instagram->_create_comment_object($_) } $instagram->_get_list( %opts, url => $url ) ]
}

1;