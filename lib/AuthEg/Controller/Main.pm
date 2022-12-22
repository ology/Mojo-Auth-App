package AuthEg::Controller::Main;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub index ($self) {
  $self->render();
}

sub login ($self) {
    my $user = $self->param('username');
    if ($self->auth($user, $self->param('password'))) {
        $self->session(auth => 1);
        return $self->redirect_to($self->url_for('accounts')->query(username => $user));
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
    my $user = $self->param('username');
    my $accounts = $self->list_accounts;
    $self->render(
        accounts => $accounts,
        user     => $user,
    );
};

sub new_user ($self) {
    my $result = $self->add($self->param('username'), $self->param('password'));

    if ( $result ) {
        $self->flash(message => 'User added');
    }
    else {
        $self->flash(error => 'Cannot add user!');
    }

    $self->redirect_to('accounts');
}

sub delete_user ($self) {
    my $user = $self->param('user');

    my $result = $self->remove($user);

    if ($result) {
        $self->flash(message => 'User removed');
    }
    else {
        $self->flash(error => 'Cannot remove user!');
    }

    $self->redirect_to('accounts');
};

1;
