#! /bin/sh
EMAIL="admin@email.com"
UPDATES=$(yum check-update --quiet | grep -v "^$")
UPDATES_COUNT=$(echo $UPDATES | wc -l)

if [[ $UPDATES_COUNT -gt 0 ]]; then
  echo $UPDATES | mail -r $EMAIL -s "Updates for $(hostname): ${UPDATES_COUNT}" $EMAIL
fi
