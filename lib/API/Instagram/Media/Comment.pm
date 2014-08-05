=head1 NAME

API::Instagram::Media::Comment - Instagram Media Comment Object

=cut

package API::Instagram::Media::Comment;

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

=head1 ATTRIBUTES

=head2 id

Returns comment id.

=head2 from

Returns commenter L<API::Instagram::User> object.

=head2 text

Returns the text commented.

=head2 created_time

Returns the comment date in a L<Time::Moment> object.

=cut

1;