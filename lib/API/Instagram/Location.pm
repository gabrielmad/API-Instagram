package API::Instagram::Location;

# ABSTRACT: Instagram Location Object

use Moo;

has _instagram => ( is => 'ro' );
has id         => ( is => 'ro' );
has latitude   => ( is => 'ro' );
has longitude  => ( is => 'ro' );
has name       => ( is => 'ro' );

=head1 SYNOPSIS

	my $location = $instagram->location(123);

	printf "Media Location: %s (%f,%f)", $location->name, $location->latitude, $location->longitude;

	for my $media ( @{ $location->recent_medias( count => 5) } ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	}

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/locations/>.

=attr id

Returns the location id.

=attr name

Returns the name of the location.

=attr latitude

Returns the latitude of the location.

=attr longitude

Returns the longitude of the location.

=method recent_medias

	my $medias = $location->recent_medias( count => 5 );
	print $_->caption . $/ for @$medias;

Returns a list of L<API::Instagram::Media> objects of recent medias from the location.

Accepts C<count>, C<min_timestamp>, C<min_id>, C<max_id> and C<max_timestamp> as parameters.

=cut

sub recent_medias {
	my $self = shift;
	my $url  = "/locations/" . $self->id . "/media/recent";
	$self->_instagram->_recent_medias( $url, @_ );
}

1;