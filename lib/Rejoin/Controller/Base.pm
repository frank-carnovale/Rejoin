package Rejoin::Controller::Base;

use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use Try::Tiny;
use Data::Dumper;
use Fcntl qw(:flock SEEK_END);

use RejoinDB;

sub lock {
    my ($c, $fh) = @_;
    flock($fh, LOCK_EX) or die "Cannot lock - $!\n";
    seek($fh, 0, SEEK_END) or die "Cannot seek - $!\n";
}

sub unlock {
    my ($c, $fh) = @_;
    flock($fh, LOCK_UN) or die "Cannot unlock mailbox - $!\n";
}

sub ok {
    my $c = shift;
    my $ip = $c->tx->remote_address;
    if ($ip eq '127.0.0.1') {
        $c->app->log->debug("ok SYSTEM");
        $c->session(system => 1);
        return 1
    }
    if (my $ti = $c->session->{tokeninfo}) {
        my $em  = $ti->{email};
        $c->app->log->debug("ok $em");
        my $voter_rs = RejoinDB->resultset('Voter');
        if (my $voter = $voter_rs->find($em)) {
            $c->stash(voter => $voter)
        }
        return 1
    }
    return $c->fail("no session") if (($c->stash('format')||'x') eq 'json');
    $c->flash(pending_req => $c->req->url);
    $c->add_flash(errors => 'Please sign in first using your Google ID.');
    $c->redirect_to('/');
    return;
}

sub fail {
    my ($c,$error) = @_;
    $c->app->log->error("Controller Error was $error");
    $c->render('exception', exception=>$error, status=>401);
    return; # ! because we often "return $c->fail.."
}

1;
