package API::Instagram::Util;

use HTTP::Request;
use LWP::UserAgent;
use Carp qw(croak);
use URI;
use Moo;
use JSON;

has _http => ( is => 'ro', default => sub { LWP::UserAgent->new() } );


use constant AUTHORIZE_URL 	=> 'https://api.instagram.com/oauth/authorize?';
use constant ACCESS_TOKEN_URL 	=> 'https://api.instagram.com/oauth/access_token?';


sub request {
	my ( $self, $url, $params, $opts ) = @_;

	croak "access_token not passed" unless defined $self->{access_token} ;

	unless ( $opts->{pagination} ){
		$params->{access_token} = $self->{access_token};

		$url = URI->new( "https://api.instagram.com/v1" . $url );
	    $url->query_form($params);
	    $url = $uri->as_string;
	}

	my $response = $self->_http->get( $url );
	my $ret = $response->decoded_content;

	my $return = eval {
		decode_json $ret
	};
	die $uri if $@;

	return decode_json $ret;
}

1;