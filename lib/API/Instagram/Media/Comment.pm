package API::Instagram::Media::Comment;

# ABSTRACT: Instagram Media Comment Object

use Moo;
use Time::Moment;

has id           => ( is => 'ro', required => 1 );
has from         => ( is => 'ro', required => 1, coerce => sub { API::Instagram->instance->user( $_[0] ) } );
has text         => ( is => 'ro', required => 1 );
has created_time => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

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

=cut

1;