use Mojo::Base -strict;
use Test::More;
use Test::Mojo::Session;
use Mojo::File qw(curfile);

my $t = Test::Mojo::Session->new(curfile->dirname->sibling('script/auth_eg'));

my $config = $t->app->config;
isa_ok $config, 'HASH';

# Allow 302 redirect responses
$t->ua->max_redirects(1);

subtest form => sub {
  $t->get_ok($t->app->url_for('index'))
    ->status_is(200)
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]')
    ->element_exists('form input[type="submit"]');
};

subtest login => sub {
  my $payload = { username => 'bogus', password => 'bogus' };
  $t->post_ok($t->app->url_for('login'), form => $payload)
    ->status_is(200)
    ->content_like(qr/Invalid/);

  $payload = { username => $config->{test_user}, password => $config->{test_pass} };
  $t->post_ok($t->app->url_for('login'), form => $payload)
    ->status_is(200)
    ->session_ok
    ->session_is('/auth' => 1)
    ->session_is('/user' => $config->{test_user});
};

subtest protected => sub {
  $t->get_ok($t->app->url_for('accounts')->query(user => $config->{test_user}))
    ->status_is(200)
    ->content_like(qr/Accounts/)
    ->content_like(qr/$config->{test_user}/)
    ->element_exists('a[href="' . $t->app->url_for('logout') . '"]');
};

subtest logout => sub {
  $t->get_ok($t->app->url_for('logout'))
    ->status_is(200)
    ->session_hasnt('/auth')
    ->session_hasnt('/user')
    ->element_exists('form input[name="username"]')
    ->element_exists('form input[name="password"]')
    ->element_exists('form input[type="submit"]');
};

done_testing();
