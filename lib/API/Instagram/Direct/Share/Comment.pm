package API::Instagram::Direct::Share::Comment;

# ABSTRACT: Instagram Direct Share Comment Object

use Moo;
use Time::Moment;

has _instagram       => ( is => 'ro' );
has id               => ( is => 'ro' );
has user             => ( is => 'ro' );
has text             => ( is => 'ro' );
has created_at => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

sub BUILD {
	my $self = shift;
	$self->{user} = $self->_instagram->user( $self->{user} );
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Direct::Share::Comment - Instagram Direct Share Comment Object

=for Pod::Coverage BUILD

=head1 VERSION

version 0.005.1

=head1 SYNOPSIS

	for my $comment ( @{ $share->comments } ){

		print $comment->text . "\n-\n";
		print "By %s, at year %d\n", $comment->user->full_name, $comment->created_at->year;

	}

=head1 DESCRIPTION

ATTENTION: No oficial documentation available. The code of this module is based on the data gaten from L<https://instagram.com/api/v1/direct_share/inbox/>.

=head1 ATTRIBUTES

=head2 id

Returns IDS comment id.

=head2 user

Returns IDS commenter L<API::Instagram::User> object.

=head2 text

Returns the text commented.

=head2 created_time

Returns the IDS comment date in a L<Time::Moment> object.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
