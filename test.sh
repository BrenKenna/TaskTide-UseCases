#!/usr/bin/env bash

set -ex

: <<'COMMENT'

Everything below is defined by you, and should be self-container. Follow the examples from this repo to help you.

Tests should be short and low storage/memory footprint example of how your contribution uses TaskTide.

For pull request test environment, a MariaDB and couchDB container will be started for you. So please 
do not edit those sections of reference micro-profile config.

This script is packaged into your contributions docker image in PR CI, and will be run from there. It is
therfore recommended to run local test of this script inside your docker image first.

All contributions are manually reviewed to ensure continutity and quality of the content of the repository.
Not as an evaluation of the validity of your use-case, the repository thus will not accept contributions
which are unlawful or harmful.

Please do not include any production grade secrets/passwords with your PR, this is not TaskTide's responsibility.

COMMENT