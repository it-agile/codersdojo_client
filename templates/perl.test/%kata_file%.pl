use strict;
use Test;

sub %kata_file% {
  "foo"
}

BEGIN { plan tests => 1, todo => [0] }

ok ("fixme", %kata_file%())
