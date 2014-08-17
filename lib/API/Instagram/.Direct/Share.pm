package API::Instagram::Direct::Share;

# ABSTRACT: Instagram Direct Share Object

use Moo;
use Time::Moment;

use API::Instagram::Direct::Share::Recipient;
use API::Instagram::Direct::Share::Comment;

has _instagram       => ( is => 'ro' );
has id               => ( is => 'ro' );
has caption          => ( is => 'ro', coerce => sub { $_[0] ? $_[0]->{text} : '' } );
has user             => ( is => 'ro' );
has recipients       => ( is => 'ro' );
has comments         => ( is => 'ro' );
has has_liked        => ( is => 'ro' );
has image_versions   => ( is => 'ro' );

has taken_at         => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );
has last_seen_at     => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );
has last_comment_at  => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );
has last_activity_at => ( is => 'ro', coerce => sub { Time::Moment->from_epoch( $_[0] ) } );

sub BUILD {
	my $self      = shift;
	my $params    = shift;
	my $instagram = $self->_instagram;
	$self->{user} = $instagram->user( $self->{user} );

	my $recipients = $params->{recipients};
	$self->{recipients} = [
		map {
			$_->{_instagram} = $instagram;
			API::Instagram::Direct::Share::Recipient->new( $_ );
		} @$recipients
	];

	my $comments = $params->{comments};
	$self->{comments} = [
		map {
			$_->{_instagram} = $instagram;
			API::Instagram::Direct::Share::Comment->new( $_ );
		} @$comments
	];
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

API::Instagram::Direct::Share - Instagram Direct Share Object

=for Pod::Coverage BUILD

=head1 VERSION

version 0.006

=head1 SYNOPSIS

	my $share = $direct->shares->[0];

	printf "Caption: %s\n", $share->caption;
	printf "Sent by %s (at %s)\n\n", $share->user->username, $share->taken_at;
	print  ( $share->has_liked ? "♥" : "♡" ) . "\n";

=head1 DESCRIPTION

ATTENTION: No oficial documentation available. The code of this module is based on the data gaten from L<https://instagram.com/api/v1/direct_share/inbox/>.

=head1 ATTRIBUTES

=head2 id

Returns IDS id.

=head2 caption

Returns IDS caption text.

=head2 taken_at

Returns the IDS date in a L<Time::Moment> object.

=head2 user

	my $sender = $share->user;
	printf "Send by %s\n", $sender->full_name;

Returns the a L<Instagram::User> object of whom sent the IDS.

=head2 recipients

Returns a list of L<API::Instagram::Direct::Share::Recipient> objects of the recipients of the IDS.

=head2 comments

Returns a list of L<API::Instagram::Direct::Share::Comment> objects of the comments of the IDS.

=head2 has_liked

	say $share->has_liked ? "♥" : "♡";

Returns if the authenticated user has liked the IDS or not.

=head2 image_versions

	for my $image ( @{ $share->image_versions } ) {
		printf "URL: %s (type %d: %d x %d)" $image->{url}, $image->{type}, $image->{width}, $image->{height};
	}

Returns Instagram Direct Share images options and details.

=head2 last_seen_at

Returns the IDS last seen date in a L<Time::Moment> object.

=head2 last_comment_at

Returns the IDS last comment date in a L<Time::Moment> object.

=head2 last_activity_at

Returns the IDS last activity date in a L<Time::Moment> object.

=head1 AUTHOR

Gabriel Vieira <gabriel.vieira@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gabriel Vieira.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
