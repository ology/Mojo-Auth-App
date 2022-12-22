use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::File qw(curfile);

my $t = Test::Mojo->new(curfile->dirname->sibling('script/auth_eg'));

my $config = $t->app->config;

isa_ok $config, 'HASH';

isa_ok $t->app->schema, 'AuthEg::DB::Schema';

my $test_user = 'test-' . time();
my $test_pass = 'abc123';

my $got = $t->app->add($test_user, $test_pass);
isa_ok $got, 'AuthEg::DB::Schema::Result::Account';

is $t->app->auth($test_user, $test_pass), 1, 'auth';

$got = $t->app->list_accounts;
isa_ok $got, 'DBIx::Class::ResultSet';

ok $t->app->remove($test_user), 'remove';
ok !$t->app->remove('bogus'), 'bogus';

done_testing();
