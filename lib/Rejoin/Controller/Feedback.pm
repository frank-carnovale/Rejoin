package Rejoin::Controller::Feedback;

use Mojo::Base 'Rejoin::Controller::Base';
use Try::Tiny;

sub post {
    my $c   = shift;

    my $voter = $c->stash('voter') || return $c->fail('has not voted yet');
    my $now = DateTime->now();
    my $ip  = $c->tx->remote_address;

    if (my $feedback = $c->param('feedback')) {
        if (length($feedback) > 40) {
            $c->add_stash(errors => 'Rejected.. feedback over 400 characters');
            $c->render(template=>'feedback/page');
            return;
        }
        $voter->add_to_feedbacks({words=>$feedback});
        $c->add_flash(messages=>"Thanks for your feedback.  It will be reviewed soon.");
    } else {
        $c->add_flash(errors=>"Feedback text missing!");
    };

    $c->redirect_to("/feedback");
}


1;
