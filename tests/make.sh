#!/bin/bash
../tools/squish.lua . -output=./tests.squished.lua
lua ../tools/wrap.lua ./tests.squished.lua ./tests.json
rm tests.squished.lua

