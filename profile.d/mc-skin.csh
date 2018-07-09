if ( $?MC_SKIN && { eval 'test ! -z "$MC_SKIN"' } ) then
  :
else
  setenv MC_SKIN "solarized-light"
endif
