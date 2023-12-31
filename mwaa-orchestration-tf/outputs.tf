output "mwaa_arn" {
  description = "arn for MWAA environment"
  value = module.mwaa.arn
}

output "mwaa_webserver_url" {
  description = "The webserver URL of the MWAA environment"
  value = module.mwaa.webserver_url
}