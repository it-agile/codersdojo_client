use strict;
use Test;

sub foo {
  "bar"
}

BEGIN { plan tests => 1, todo => [0] }

ok ("bar", foo())
