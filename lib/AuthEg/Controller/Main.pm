package AuthEg::Controller::Main;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub authorize ($self) {
    my $auth = $self->session('auth') // '';
    return 1 if $auth;

    $self->render(text => 'Denied!');
    return 0;
}

sub index ($self) { $self->render; }

sub login ($self) {
    my $v = $self->validation;
    $v->required('username')->size(3, 50);
    $v->required('password')->size(3, 50);
    if ($v->error('username') || $v->error('password')) {
      $self->flash(error => 'Invalid login');
      return $self->redirect_to('index');
    }

    my $user = $v->param('username');

    if ($self->auth($user, $v->param('password'))) {
        $self->session(auth => 1, user => $user);
        return $self->redirect_to('accounts');
    }

    $self->flash(error => 'Invalid login');
    $self->redirect_to('index');
}

sub logout ($self) {
    delete $self->session->{auth};
    delete $self->session->{user};

    $self->redirect_to('index');
};

sub accounts ($self) {
    my $accounts = $self->list_accounts;

    $self->render(
        accounts => $accounts,
        user     => $self->session->{user},
    );
};

sub new_user ($self) {
    my $v = $self->validation;
    $v->required('username')->size(3, 50);
    $v->required('password')->size(3, 50);
    if ($v->error('username') || $v->error('password')) {
      $self->flash(error => 'Invalid submission');
      return $self->redirect_to('accounts');
    }

    my $result = $self->add($v->param('username'), $v->param('password'));

    if ($result) {
        $self->flash(message => 'User ' . $result->id . ' added');
    }
    else {
        $self->flash(error => 'Cannot add user!');
    }

    $self->redirect_to('accounts');
}

sub delete_user ($self) {
    my $id = $self->param('id');

    my $result = $self->remove($id);

    if ($result) {
        $self->flash(message => "User $id removed");
    }
    else {
        $self->flash(error => 'Cannot remove user!');
    }

    $self->redirect_to('accounts');
};

1;
