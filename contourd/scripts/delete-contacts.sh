#!/bin/zsh
# deletes qtmobility contacts from nepomuk
alias nepomukcmd="sopranocmd --socket `kde4-config --path socket`nepomuk-socket --model main --nrl"
for res in `nepomukcmd --foo query 'select ?contact where { ?contact a nco:Contact . ?contact nie:url ?url . FILTER (regex(?url , "^qt")) }'`; nepomukcmd rm $res
