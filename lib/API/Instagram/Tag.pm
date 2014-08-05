=head1 NAME

API::Instagram::Tag - Instagram Tag Object

=cut

package API::Instagram::Tag;

use Moo;

has _instagram  => ( is => 'ro' );
has name        => ( is => 'ro' );
has media_count => ( is => 'ro' );

=head1 SYNOPSIS

	my $tag = $instagram->tag('perl');

	printf "Count: %s", $tag->media_count;

	for my $media ( @{ $tag->recent_medias( count => 5) } ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	}

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/tags/>.

=head1 ATTRIBUTES

=head2 name

Returns the Tag name.

=head2 media_count

Returns the total media tagged with it.

=head1 METHODS

=head2 recent_medias

	my $medias = $tag->recent_medias( count => 5 );
	print $_->caption . $/ for @m$edias;

Returns a list of L<API::Instagram::Media> objects of recent medias tagged with it.

Accepts C<count>, C<min_timestamp>, C<min_id>, C<max_id> and C<max_timestamp> as parameters.

=cut

sub recent_medias {
	my $self = shift;
	my $url  = "/tags/" . $self->name . "/media/recent";
	$self->_instagram->_recent_medias( $url, @_ );
}

1;