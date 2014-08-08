
# wpmaintenance: Enable/disable WordPress maintenance in current dir
function wpmaintenance() {
  if [[ -f .maintenance ]]; then
    echo "Disabling WordPress maintenance..."
    rm .maintenance
  else
    echo "Enabling WordPress maintenance..."
    echo '<?php $upgrading = '`date +%s`'; ?>' > .maintenance
  fi

  echo "done."
}
