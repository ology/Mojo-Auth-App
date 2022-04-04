package AuthEg::Controller::Main;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($self) {
  $self->render();
}

sub login ($self) {
    if ($self->auth($self->param('username'), $self->param('password'))) {
        $self->session(auth => 1);
        return $self->redirect_to('accounts');
    }
    $self->flash(error => 'Invalid login');
    $self->redirect_to('index');
}

sub logout ($self) {
    delete $self->session->{auth};
    $self->redirect_to('index');
};

sub authorize ($self) {
    my $session = $self->session('auth') // '';

    return 1 if $session;

    $self->render(text => 'Denied!');
    return 0;
}

sub accounts ($self) {
    my $accounts = $self->list_accounts;
    $self->render(accounts => $accounts);
};

sub add ($self) {
    my $result = $self->add($self->param('username'), $self->param('password'));

    if ( $result ) {
        $self->flash(message => 'User added');
    }
    else {
        $self->flash(error => 'Cannot add user!');
    }

    $self->redirect_to('accounts');
}

1;
