#!/usr/bin/env perl


use Modern::Perl;
use Array::Utils qw(:all);
use Data::Dumper;

use lib "lib";
use API::Instagram;


my $instagram = API::Instagram->new({
	client_id		=> '29b16a34e1cb4e79a125dc62f469f8e4',
	client_secret	=> 'a8be5021299b450bbe0e52a6db174587',
	redirect_uri	=> 'http://localhost',
	no_cache        => 0,
});


# my $auth_url = $instagram->get_auth_url();

# print $auth_url.$/;
# exit;
=cut
# my $code = $instagram->get_code($auth_url);

# print Dumper $code;

# exit;
my $code ='3556086fe53e492587d96fd68900b374';
$instagram->set_code( $code );

my $access_token = $instagram->get_access_token();

print Dumper $access_token;
# my $media = $instagram->media('766293877319431295_254787972');


# print Dumper $instagram->user('20547561')->feed;
# exit;
# print Dumper $instagram->tag('botafogo');
# exit;
=cut



my $access_token = '254787972.29b16a3.500f79983b84481c9157b27cba8e509d';
$instagram->access_token( $access_token );

	my $my_user = $instagram->user;
	my $feed    = $my_user->feed( count => 5 );

	for my $media ( @$feed ) {

		printf "Caption: %s\n", $media->caption;
		printf "Posted by %s at %s (%d likes)\n\n",	$media->user->username,
													$media->created_time,
													$media->likes;
	}

exit;

my $user      = $instagram->user;
my $followers = $user->get_followers;
my $medias    = $user->recent_medias( count => -1 );

print "Total medias: " . ~~@$medias;
print $/x2;


my $likers;
my $commenters;
my $active_users;

my $i = 0;
for my $media ( reverse @$medias ) {

	my $caption = $media->caption;
	my $likes   = $media->likes;

	my $likers     = $media->get_likes;
	my $commenters = $media->get_comments;

	$active_users->{ $_->id }       = $_       for @$likers;
	$active_users->{ $_->from->id } = $_->from for @$commenters;

	print "Picture ".++$i.": $caption$/";
	print "Likes: $likes - " . @$likers . $/;
}

$active_users = [ values $active_users ];

print "Total followers: " . ~~@$followers;
print $/x2;

print "Active users: " .  ~~@$active_users;
print $/x2;


my @x = map { $_->username } @$active_users;
my @y = map { $_->username } @$followers   ;

print Dumper \@x;
<>;


my @not_following = array_minus( @x, @y );
print "Not following: ".~~@not_following;
<>;
print Dumper \@not_following;
print $/x2;

my @ghosts = array_minus( @y, @x );
print "Ghosts: " . ~~@ghosts;
<>;
print Dumper \@ghosts;
print $/x2;


$instagram->print_total;
