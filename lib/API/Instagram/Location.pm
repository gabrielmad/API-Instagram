package API::Instagram::Location;

# ABSTRACT: Instagram Location Object

use Moo;

has _instagram => ( is => 'ro' );
has id         => ( is => 'ro' );
has latitude   => ( is => 'ro' );
has longitude  => ( is => 'ro' );
has name       => ( is => 'ro' );


sub recent_medias {
	my $self = shift;
	my $url  = "/locations/" . $self->id . "/media/recent";
	$self->_instagram->_recent_medias( $url, @_ );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Location - Instagram Location Object

=head1 VERSION

version 0.005

=head1 SYNOPSIS

	my $location = $instagram->location(123);

	printf "Media Location: %s (%f,%f)", $location->name, $location->latitude, $location->longitude;

	for my $media ( @{ $location->recent_medias( count => 5) } ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s (%d likes)\n\n", $media->user->username, $media->likes;

	}

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/locations/>.

=head1 ATTRIBUTES

=head2 id

Returns the location id.

=head2 name

Returns the name of the location.

=head2 latitude

Returns the latitude of the location.

=head2 longitude

Returns the longitude of the location.

=head1 METHODS

=head2 recent_medias

	my $medias = $location->recent_medias( count => 5 );
	print $_->caption . $/ for @$medias;

Returns a list of L<API::Instagram::Media> objects of recent medias from the location.

Accepts C<count>, C<min_timestamp>, C<min_id>, C<max_id> and C<max_timestamp> as parameters.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
