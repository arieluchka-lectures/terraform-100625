locals {
  start_sh = templatefile("${path.module}/scripts/user_scripts.sh",
    {
      MYSQL_DATABASE        = "Hogwarts"
      MYSQL_ROOT_PASSWORD   = "hipo"
      TS3SERVER_DB_PASSWORD = "hipo"
      TS3SERVER_DB_NAME     = "Hogwarts"
  })


}