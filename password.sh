#!/bin/bash
date +%s | sha256sum | base64 | head -c 8 ; echo
