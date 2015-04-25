#!/bin/sh

dir=${0%/*}
if [ -d "$dir" ]; then
  cd "$dir"
fi

echo ""
echo "Do not close this window until you are done using Targets!"
echo ""

targets gui 7620 http://mvhs.darttargets.com