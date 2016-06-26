package Rejoin::Controller::Oauth2;

use Mojo::Base 'Rejoin::Controller::Base';

use Mojo::UserAgent;

my $URL_TOKENINFO = 'https://www.googleapis.com/oauth2/v3/tokeninfo';
my $SIGNIN_FILE = "/var/log/rejoin/signin";

my @tokenfields = (
    qw/alg at_hash aud azp email email_verified exp family_name given_name iat iss kid locale name picture sub/
);
 
sub signin {
    my $c = shift;
    my $log = $c->app->log;

    # verify token at google..
    my $id_token = $c->req->param('id_token');
    $log->debug("id_token is $id_token");
    my $ua = Mojo::UserAgent->new;
    my $tx  = $ua->post($URL_TOKENINFO => form => { id_token => $id_token });
    if (my $error = $tx->error) {
        $c->app->log->error("$URL_TOKENINFO: " . $c->dumper($error));
        return $c->fail("failed to authenticate");
    }
    my $tokeninfo = $tx->res->json;
    $c->app->log->info("new tokeninfo " . $c->dumper($tokeninfo));
    return $c->fail("client-id did not match")
        if $tokeninfo->{aud} ne $c->app->config->{OAUTH2_CLIENT_ID};

    if (0) {
        # .. and record this!
        $tokeninfo->{ip} = $c->tx->remote_address;
        open (my $trail, ">>", $SIGNIN_FILE) or die "$SIGNIN_FILE: $!\n";
        $c->lock($trail); # perldoc -f flock
        print $trail Dumper($tokeninfo);
        $c->unlock($trail);
    }

    # finally.. could reduce tokeninfo fields to sub,picture,name,email
    $c->session(tokeninfo => $tokeninfo);
    $c->render(json=>$tokeninfo);
}

sub signout {
    my $c = shift;
    my $tokeninfo = $c->session->{tokeninfo} || return $c->fail('already no session');
    delete $c->session->{tokeninfo};
    $c->session(expires => 1);
    $c->render(json=>'OK');
}

1;
