#!/usr/bin/env sh
# w3schools.com

../bin/moby --url https://www.w3schools.com/html/tryit.asp?filename=tryhtml_form_submit --username_is_email_address --debug --verbose
