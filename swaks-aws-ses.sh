#!/bin/sh

echo "Test SMTP server in AWS (SES - Simple Email Service)"
swaks --to david.pasek@gmail.com \
  --from=notfications@dpasek.com \
  --auth \
  --auth-user=AKIAWJBJMHQSKYHX3RFS \
  --auth-password \
  --tls \
  --server email-smtp.us-east-1.amazonaws.com \

