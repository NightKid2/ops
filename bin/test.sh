#!/bin/bash
grep PROMPT_COMMAND /etc/profile &>/dev/null || cat  <<EOF >>/etc/profile 
export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "\$(whoami)" [\$(pwd)] "\$msg"; }'
EOF
