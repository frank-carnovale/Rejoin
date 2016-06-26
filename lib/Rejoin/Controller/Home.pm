package Rejoin::Controller::Home;

use Mojo::Base 'Rejoin::Controller::Base';

sub page {
    my $c = shift;
    my $outcome = RejoinDB->resultset('Outcome')->find(1) || die 'no outcome row';
    my $voter_rs = RejoinDB->resultset('Voter');
    my $ti = $c->session->{tokeninfo};
    if (my $voter = $voter_rs->find($ti->{email})) {
        $c->stash(voter => $voter);
    }
    $c->stash(outcome => $outcome);
}

1;
