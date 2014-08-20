package API::Instagram::Tag;

# ABSTRACT: Instagram Tag Object

use Moo;

has _api        => ( is => 'ro', required => 1 );
has name        => ( is => 'ro', required => 1 );

=head1 SYNOPSIS

	my $tag = $instagram->tag('perl');

	printf "Count: %s", $tag->media_count;

	for my $media ( @{ $tag->recent_medias( count => 5) } ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	}

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/tags/>.

=attr name

Returns the Tag name.

=attr media_count

Returns the total media tagged with it.

=cut
sub media_count { shift->_load('media_count') }

=method recent_medias

	my $medias = $tag->recent_medias( count => 5 );
	print $_->caption . $/ for @m$edias;

Returns a list of L<API::Instagram::Media> objects of recent medias tagged with it.

Accepts C<count>, C<min_timestamp>, C<min_id>, C<max_id> and C<max_timestamp> as parameters.

=cut

sub recent_medias {
	my $self = shift;
	my $url  = sprintf "tags/%s/media/recent", $self->name;
	$self->_api->_recent_medias( $url, @_ );
}

sub _load {
	my $self = shift;
	my $attr = shift;

	my $url  = sprintf "tags/%s", $self->name;
	my $res  = $self->_api->_request_data($url);

	$attr ? $res->{$attr} : $res;
}

1;