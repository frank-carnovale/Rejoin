package Rejoin::Controller::Vote;

use Mojo::Base 'Rejoin::Controller::Base';
use Try::Tiny;

sub how {
    my $c   = shift;
    my $how = $c->stash('how');
    my $now = DateTime->now();
    my $fn  = "/var/log/rejoin/$how";
    my $ip  = $c->tx->remote_address;
    my $ti  = $c->session->{tokeninfo} || die 'session fail';
    my $em  = $ti->{email};
    my ($rejoin, $b_rejoin);
    if ($how eq 'stay') {
        $rejoin   = 'I';
        $b_rejoin = 1;
    } else {
        $rejoin   = 'X';
        $b_rejoin = 0;
    }

    open (my $fh, ">>", $fn) or die "$fn $!\n";
    $c->lock($fh);
    printf $fh "%s|%s|%s\n", $now, $ip, $em;
    $c->unlock($fh);
    close($fh);

    my ($stay, $quit) = (-1, -1);
    my $txn = sub {
        my $voter_rs = RejoinDB->resultset('Voter');
        my $voter    = $voter_rs->find($em);
        return if $voter && $voter->rejoin eq $rejoin;
        my $outcome = RejoinDB->resultset('Outcome')->find(1) || die 'no outcome row';
        $stay = $outcome->stay;
        $quit = $outcome->quit;
        if ($voter) {
            $b_rejoin? $outcome->quit(--$quit): $outcome->stay(--$stay);
            $voter->update({
                vote_ts => $now,
                ip      => $ip,
                rejoin  => $rejoin
            })
        } else {
            $voter_rs->create({
                gmail   => $em,
                rejoin  => $rejoin,
                vote_ts => $now,
                join_ts => $now,
                ip      => $ip,
                name    => $ti->{name},
            })
        }
        $b_rejoin? $outcome->stay(++$stay): $outcome->quit(++$quit);
        $outcome->update;
    };

    try {
        RejoinDB->txn_do($txn);
    } catch {
        return $c->fail("vote txn failed: $_")
    };

    my $json = { result=>'ok', stay=>$stay, quit=>$quit };
    $c->render( json=>$json );
}

1;
