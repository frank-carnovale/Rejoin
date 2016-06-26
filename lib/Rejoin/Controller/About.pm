package Rejoin::Controller::About;

use Mojo::Base 'Rejoin::Controller::Base';

sub page {
    my $c = shift;
    my $voter_rs = RejoinDB->resultset('Voter');
    my $ti = $c->session->{tokeninfo};
    if (my $voter = $voter_rs->find($ti->{email})) {
        $c->stash(voter => $voter);
    }
}

1;
