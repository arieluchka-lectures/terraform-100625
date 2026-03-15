locals {

  credentials = {
    MYSQL_DATABASE        = "Hogwarts"
    MYSQL_ROOT_PASSWORD   = "hipo"
    TS3SERVER_DB_PASSWORD = "hipo"
    TS3SERVER_DB_NAME     = "Hogwarts"
  }
  start_sh = templatefile("${path.module}/scripts/user_scripts.sh", local.credentials
  )

  # debug_sh = templatefile("${path.module}/scripts/debug_tools.sh", {}
  # ) # disable post debugging





}