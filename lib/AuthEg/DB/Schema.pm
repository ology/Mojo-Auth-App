use utf8;
package AuthEg::DB::Schema;

use strict;
use warnings;

# This module allows schema connect via the dbic.yaml file
use base 'DBIx::Class::Schema::Config';

__PACKAGE__->load_namespaces;

1;
