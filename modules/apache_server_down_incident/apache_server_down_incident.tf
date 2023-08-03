resource "shoreline_notebook" "apache_server_down_incident" {
  name       = "apache_server_down_incident"
  data       = file("${path.module}/data/apache_server_down_incident.json")
  depends_on = [shoreline_action.invoke_restart_apache_service,shoreline_action.invoke_apache_service_check,shoreline_action.invoke_apache_conf_syntax_check]
}

resource "shoreline_file" "restart_apache_service" {
  name             = "restart_apache_service"
  input_file       = "${path.module}/data/restart_apache_service.sh"
  md5              = filemd5("${path.module}/data/restart_apache_service.sh")
  description      = "Restart Apache service"
  destination_path = "/agent/scripts/restart_apache_service.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "apache_service_check" {
  name             = "apache_service_check"
  input_file       = "${path.module}/data/apache_service_check.sh"
  md5              = filemd5("${path.module}/data/apache_service_check.sh")
  description      = "Check service status again"
  destination_path = "/agent/scripts/apache_service_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "apache_conf_syntax_check" {
  name             = "apache_conf_syntax_check"
  input_file       = "${path.module}/data/apache_conf_syntax_check.sh"
  md5              = filemd5("${path.module}/data/apache_conf_syntax_check.sh")
  description      = "Check for any configuration errors or updates that may have caused the issue and correct them as needed."
  destination_path = "/agent/scripts/apache_conf_syntax_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_restart_apache_service" {
  name        = "invoke_restart_apache_service"
  description = "Restart Apache service"
  command     = "`chmod +x /agent/scripts/restart_apache_service.sh && /agent/scripts/restart_apache_service.sh`"
  params      = []
  file_deps   = ["restart_apache_service"]
  enabled     = true
  depends_on  = [shoreline_file.restart_apache_service]
}

resource "shoreline_action" "invoke_apache_service_check" {
  name        = "invoke_apache_service_check"
  description = "Check service status again"
  command     = "`chmod +x /agent/scripts/apache_service_check.sh && /agent/scripts/apache_service_check.sh`"
  params      = []
  file_deps   = ["apache_service_check"]
  enabled     = true
  depends_on  = [shoreline_file.apache_service_check]
}

resource "shoreline_action" "invoke_apache_conf_syntax_check" {
  name        = "invoke_apache_conf_syntax_check"
  description = "Check for any configuration errors or updates that may have caused the issue and correct them as needed."
  command     = "`chmod +x /agent/scripts/apache_conf_syntax_check.sh && /agent/scripts/apache_conf_syntax_check.sh`"
  params      = ["PATH_TO_APACHE_CONF_FILE"]
  file_deps   = ["apache_conf_syntax_check"]
  enabled     = true
  depends_on  = [shoreline_file.apache_conf_syntax_check]
}

