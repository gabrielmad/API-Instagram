package API::Instagram::Media::Comment;

# ABSTRACT: Instagram Media Comment Object

use Moo;
use Time::Moment;

has _instagram   => ( is => 'ro' );
has id           => ( is => 'ro' );
has from         => ( is => 'ro' );
has text         => ( is => 'ro' );
has created_time => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

sub BUILD {
	my $self = shift;
	$self->{from} = $self->_instagram->user( $self->{from} );
}

=head1 SYNOPSIS

	print $comment->text . "\n-\n";
	print "By %s, at year %d\n", $comment->from->full_name, $comment->created_time->year;

=head1 DESCRIPTION

See L<http://instagr.am/developer/endpoints/comments/>.

=attr id

Returns comment id.

=attr from

Returns commenter L<API::Instagram::User> object.

=attr text

Returns the text commented.

=attr created_time

Returns the comment date in a L<Time::Moment> object.

=for Pod::Coverage BUILD
=cut

1;