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

my $user = $t->app->add($test_user, $test_pass);
isa_ok $user, 'AuthEg::DB::Schema::Result::Account';

is $t->app->auth($test_user, $test_pass), 1, 'auth';

my $got = $t->app->list_accounts;
isa_ok $got, 'DBIx::Class::ResultSet';
my @accounts;
while (my $account = $got->next) {
  push @accounts, $account;
}
is scalar(@accounts), 1, 'one account';

ok $t->app->remove($user->id), 'remove';
ok !$t->app->remove(0), 'bogus';

done_testing();
