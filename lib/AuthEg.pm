package AuthEg;
use Mojo::Base 'Mojolicious', -signatures;

use Mojolicious::Plugin::Bcrypt;

sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  $self->plugin('bcrypt', { key_nul => 0, cost => 6 });

  # 
  $self->plugin('AuthEg::DB::Plugin');

  # Router
  my $r = $self->routes;

  $r->get('/')->to('Main#index')->name('index');
  $r->post('/login')->to('Main#login')->name('login');
  $r->get('/logout')->to('Main#logout')->name('logout');
  my $authed = $r->under('/authed')->to('Main#authorize');
  $authed->get('/accounts')->to('Main#accounts')->name('accounts');
}

1;
