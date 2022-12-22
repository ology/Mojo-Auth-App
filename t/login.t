use Mojo::Base -strict;
use Test::More;
use Test::Mojo::Session;
use Mojo::File qw(curfile);

my $t = Test::Mojo::Session->new(curfile->dirname->sibling('script/auth_eg'));

my $config = $t->app->config;
isa_ok $config, 'HASH';

# Allow 302 redirect responses
$t->ua->max_redirects(1);

# Test if the HTML login form exists
$t->get_ok('/')
  ->status_is(200)
  ->element_exists('form input[name="username"]')
  ->element_exists('form input[name="password"]')
  ->element_exists('form input[type="submit"]');

# Test login with valid credentials
$t->post_ok('/login' => form => { username => $config->{test_user}, password => $config->{test_pass} })
  ->status_is(200)
  ->session_ok
  ->session_is('/auth' => 1)
  ->session_is('/user' => $config->{test_user});

# Test accessing a protected page
$t->get_ok('/authed/accounts?user=foo')
  ->status_is(200)
  ->content_like(qr/Accounts/)
  ->element_exists('a[href="/logout"]');

# Test if HTML login form shows up again after logout
$t->get_ok('/logout')
  ->status_is(200)
  ->session_hasnt('/auth')
  ->element_exists('form input[name="username"]')
  ->element_exists('form input[name="password"]')
  ->element_exists('form input[type="submit"]');

done_testing();
