#!/bin/sh

HOME_DIR=/home/elab
ELAB_DIR=${HOME_DIR}/app/elabsheet
SETUP_DIR=/root/scripts/output/setup-elab

cp ${SETUP_DIR}/tqfauthen.py ${ELAB_DIR}/lab/backends/
chown elab:elab ${ELAB_DIR}/lab/backends/tqfauthen.py
chown elab:elab ${ELAB_DIR}/elabsheet/settings_local.py
chmod go-rwx ${ELAB_DIR}/elabsheet/settings_local.py

cd ${ELAB_DIR}
./install-box.sh

su -c "
  cd ${ELAB_DIR}
  ./install-dirs.sh
" - elab
chown elab:elab ${ELAB_DIR}/public/media

cat > ${ELAB_DIR}/create_admin.py << EOF
from django.contrib.auth.models import User
if "${DJANGO_ADMIN_USER}" != "":
  try:
    user=User.objects.create_user("${DJANGO_ADMIN_USER}", password="${DJANGO_ADMIN_PASSWORD}")
    user.is_superuser=True
    user.is_staff=True
    user.save()
  except:
    pass
EOF
chown elab:elab ${ELAB_DIR}/create_admin.py

while ! nc -z db 3306 > /dev/null; do
  echo 'Waiting for database to be ready...'
  sleep 1
done

su -c "
  . ${HOME_DIR}/virtualenv/elab/bin/activate ve
  cd ${ELAB_DIR}
  ./manage.py migrate
  ./manage.py collectstatic_js_reverse
  ./manage.py collectstatic --noinput
  ./manage.py shell -c 'import create_admin'
  rm create_admin.py
  cd ${HOME_DIR}
  ./gunicorn-start-elab.sh
" - elab
