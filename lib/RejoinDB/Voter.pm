package RejoinDB::Voter;

use strict;
use warnings;

sub stringify {
    my $self = shift;
    sprintf "%s voted %s on %s",
            $self->name,
            ($self->rejoin eq 'I'? 'Rejoin': 'Stay-Out'),
            $self->vote_ts->strftime('%F at %T')
}

1;

