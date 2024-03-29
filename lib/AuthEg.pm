package AuthEg;
use Mojo::Base 'Mojolicious', -signatures;

sub startup ($self) {
  $self->plugin('AuthEg::DB::Plugin');

  my $config = $self->plugin('NotYAMLConfig');

  $self->secrets($config->{secrets});

  my $r = $self->routes;
  $r->get('/')      ->to('Main#index') ->name('index');
  $r->post('/login')->to('Main#login') ->name('login');
  $r->get('/logout')->to('Main#logout')->name('logout');
  my $authed = $r->under('/authed')->to('Main#authorize');
  $authed->get('/accounts')->to('Main#accounts')   ->name('accounts');
  $authed->post('/add')    ->to('Main#new_user')   ->name('add');
  $authed->get('/remove')  ->to('Main#delete_user')->name('remove');
}

1;
