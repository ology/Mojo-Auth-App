use utf8;
package AuthEg::DB::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema::Config'; # NOTE ::Config allows schema connect

__PACKAGE__->load_namespaces;

1;
