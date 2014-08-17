package API::Instagram::Direct::Share::Recipient;

# ABSTRACT: Instagram Direct Share Recipient Object

use Moo;

has _instagram       => ( is => 'ro' );
has user             => ( is => 'ro' );
has status           => ( is => 'ro' );
has has_seen         => ( is => 'ro' );
has has_liked        => ( is => 'ro' );
has has_commented    => ( is => 'ro' );

sub BUILD {
	my $self = shift;
	$self->{user} = $self->_instagram->user( $self->{user} );
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Direct::Share::Recipient - Instagram Direct Share Recipient Object

=for Pod::Coverage BUILD

=head1 VERSION

version 0.005.1

=head1 SYNOPSIS

	for my $recipient ( @{ $share->recipients } ){

		printf "%s status is %s.\n", $recipient->user->full_name, $recipient->status;

	}

=head1 DESCRIPTION

ATTENTION: No oficial documentation available. The code of this module is based on the data gaten from L<https://instagram.com/api/v1/direct_share/inbox/>.

=head1 ATTRIBUTES

=head2 user

Returns recipient L<API::Instagram::User> object.

=head2 status

Retuns recipient status related to the IDS (e.g. C<unseen>, C<seen>, C<liked> ).

=head2 has_seen

Returns if the recipient has seen the IDS or not.

=head2 has_liked

Returns if the recipient has liked the IDS or not.

=head2 has_commented

Returns if the recipient has commented the IDS or not.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
