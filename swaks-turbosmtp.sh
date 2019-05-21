#!/bin/sh

echo "Test SMTP server in TurboSMTP"
swaks --to david.pasek@gmail.com \
  --from=david@dpasek.com \
  --auth \
  --auth-user=david.pasek@flexbook.cz \
  --auth-password \
  --server pro.eu.turbo-smtp.com \

