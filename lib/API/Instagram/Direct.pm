package API::Instagram::Direct;

# ABSTRACT: Instagram Direct Object

use Moo;
use Carp;

has _instagram => ( is => 'ro' );
has new_shares => ( is => 'ro' );
has shares     => ( is => 'ro' );
# has last_counted_at => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } ); );

sub BUILD {
	my $self   = shift;
	my $params = shift;

	confess 'Error during Instagram Direct access' if $params->{status} ne 'ok';

	$self->{new_shares} = $params->{new_shares_info}->{count} || 0;

	my $shares = $params->{shares};
	$self->{shares} = [
		map {
			$_->{_instagram} = $self->_instagram;
			API::Instagram::Direct::Share->new( $_ );
		} @$shares
	];
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Direct - Instagram Direct Object

=for Pod::Coverage BUILD

=head1 VERSION

version 0.006

=head1 DESCRIPTION

ATTENTION: No oficial documentation available. The code of this module is based on the data gaten from L<https://instagram.com/api/v1/direct_share/inbox/>.

=head1 ATTRIBUTES

=head2 new_shares

	printf "You have total of %d Instagram Direct Shares\n", $direct->new_shares;

Returns total of new Direct Shares.

=head2 shares

	for my $share ( @{ $direct->shares } ){

		printf "Caption: %s\n", $share->caption;
		printf "Shared between %d people\n\n", ~~@{ $share->recipients };

	}

Returns a list of L<API::Instagram::Direct::Share> objects of the direct shared medias.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
