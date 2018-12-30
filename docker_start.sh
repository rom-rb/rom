#!/bin/sh
bundle check || bundle install
tail -f Gemfile
