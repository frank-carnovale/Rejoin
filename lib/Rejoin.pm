package Rejoin;
use Mojo::Base 'Mojolicious';

use RejoinDB;

sub startup {
    my $app = shift;

    $app->plugin('StaticLog');
    $app->plugin('Config');
    $app->secrets(['4r7e3e5j5o3i9n']);

    $app->config(hypnotoad => {
        listen => ['http://*:3001'],
        pid_file => '/tmp/hypnotoad_rejoin.pid',
    });

    $app->helper(add_stash => sub {
        my ($c, $slot, $val) = @_;
        push @{$c->stash->{$slot} ||= []}, $val;
    });

    $app->helper(add_flash => sub {
        my ($c, $slot, $val) = @_;
        push @{$c->session->{new_flash}{$slot} ||= []}, $val;
    });

    RejoinDB->setup;

    # Router
    my $r = $app->routes;
    $r->get('/' => [format=>0])->to('home#page');
    $r->get('/about')->to('about#page');
    $r->get('/die')->to(cb=>sub {die "user requested error\n"});

    $r->post('/oauth2/signin')->to('oauth2#signin');
    $r->post('/oauth2/signout')->to('oauth2#signout');

    for ($r->under('/vote/:how' => [how=>["stay","quit"]] )->to('vote#ok')) {
        $_->post->to('vote#how')
    }
    for ($r->under('/feedback')->to('feedback#ok')) {
        $_->get->to('feedback#page');
        $_->post->to('feedback#post');
    }
}

1;

