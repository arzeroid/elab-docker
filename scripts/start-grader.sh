#!/bin/sh

HOME_DIR=/home/elab
ELAB_DIR=${HOME_DIR}/app/elabsheet

su -c "
  . ${HOME_DIR}/virtualenv/elab/bin/activate ve
  cd ${ELAB_DIR}
  sleep 20  # wait for db (TODO: write a better script)
  ./manage.py run_grader
" elab
