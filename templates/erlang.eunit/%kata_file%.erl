-module(%kata_file%).
-export([%kata_file%/0]).
-include_lib("eunit/include/eunit.hrl").


%kata_file%() ->
  true.

%kata_file%_test_() ->
  { setup,
   fun setup/0,
   fun cleanup/1,[ 
     ?_assert(%kata_file%())
   ]}.
       
setup() ->
  ok.

cleanup(_Pid) ->
  ok.
