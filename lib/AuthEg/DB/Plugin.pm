package AuthEg::DB::Plugin;
use Mojo::Base 'Mojolicious::Plugin';

use AuthEg::DB::Schema;

sub register {
    my ($self, $app) = @_;

    $app->helper(schema => sub {
        my ($c) = @_;
        return state $schema = AuthEg::DB::Schema->connect('db');
    });

    $app->helper(auth => sub {
        my ($c, $user, $pass) = @_;

        my $result = $c->schema->resultset('Account')->search({ name => $user })->first;

        return 1
            if $result && $result->check_password($pass);
    });

    $app->helper(add => sub {
        my ($c, $user, $pass) = @_;

        return 0
            unless $user && $pass;

        my $result = $c->schema->resultset('Account')->search({ name => $user })->first;
        return 0
            if $result;

        $result = $c->schema->resultset('Account')->create({ name => $user, password => $pass });

        return $result;
    });

    $app->helper(remove => sub {
        my ($c, $id) = @_;

        my $result = $c->schema->resultset('Account')->search({ id => $id })->first;
        $result->delete if $result;

        return $result ? 1 : 0;
    });

    $app->helper(list_accounts => sub {
        my ($c) = @_;

        my $result = $c->schema->resultset('Account')->search({}, { order_by => 'name' });

        return $result;
    });

}

1;
