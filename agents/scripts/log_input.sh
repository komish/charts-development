#!/usr/bin/env bash

# Just take the input and write it to a file in the base dir.

INPUT=$(cat)
echo "${INPUT}" >> pre_tool_use.log

# ... TBD other operations we might want to do with the input for observability.
