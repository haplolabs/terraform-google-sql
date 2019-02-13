# ------------------------------------------------------------------------------
# SEPARATE TERRAFORM FILE TO COMPUTE OUTPUT VALUES AND KEEP THE MAIN MODULE CLEAN
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# PREPARE LOCALS FOR THE OUTPUTS
# ------------------------------------------------------------------------------

locals {
  # Replica proxy connection info
  failover_proxy_connection = "${join("",data.template_file.failover_proxy_connection.*.rendered)}"

  # Replica certificate info
  failover_certificate                  = "${join("",data.template_file.failover_certificate.*.rendered)}"
  failover_certificate_common_name      = "${join("",data.template_file.failover_certificate_common_name.*.rendered)}"
  failover_certificate_create_time      = "${join("",data.template_file.failover_certificate_create_time.*.rendered)}"
  failover_certificate_expiration_time  = "${join("",data.template_file.failover_certificate_expiration_time.*.rendered)}"
  failover_certificate_sha1_fingerprint = "${join("",data.template_file.failover_certificate_sha1_fingerprint.*.rendered)}"
}

# ------------------------------------------------------------------------------
# FAILOVER REPLICA PROXY CONNECTION TEMPLATE
# ------------------------------------------------------------------------------

data "template_file" "failover_proxy_connection" {
  count    = "${var.enable_failover_replica}"
  template = "${var.project}:${var.region}:${google_sql_database_instance.failover_replica.0.name}"
}

# ------------------------------------------------------------------------------
# FAILOVER REPLICA CERTIFICATE TEMPLATES
#
# We have to produce the certificate outputs via template_file. Using splat syntax would yield:
# Resource 'google_sql_database_instance.failover_replica' does not have attribute 'server_ca_cert.0.cert'
# for variable 'google_sql_database_instance.failover_replica.*.server_ca_cert.0.cert'
# ------------------------------------------------------------------------------

data "template_file" "failover_certificate" {
  count    = "${var.enable_failover_replica}"
  template = "${google_sql_database_instance.failover_replica.0.server_ca_cert.0.cert}"
}

data "template_file" "failover_certificate_common_name" {
  count    = "${var.enable_failover_replica}"
  template = "${google_sql_database_instance.failover_replica.0.server_ca_cert.0.common_name}"
}

data "template_file" "failover_certificate_create_time" {
  count    = "${var.enable_failover_replica}"
  template = "${google_sql_database_instance.failover_replica.0.server_ca_cert.0.create_time}"
}

data "template_file" "failover_certificate_expiration_time" {
  count    = "${var.enable_failover_replica}"
  template = "${google_sql_database_instance.failover_replica.0.server_ca_cert.0.expiration_time}"
}

data "template_file" "failover_certificate_sha1_fingerprint" {
  count    = "${var.enable_failover_replica}"
  template = "${google_sql_database_instance.failover_replica.0.server_ca_cert.0.sha1_fingerprint}"
}

# ------------------------------------------------------------------------------
# READ REPLICA PROXY CONNECTION TEMPLATE
# ------------------------------------------------------------------------------

data "template_file" "read_replica_proxy_connection" {
  count    = "${var.num_read_replicas}"
  template = "${var.project}:${var.region}:${google_sql_database_instance.read_replica.*.name[count.index]}"
}

# ------------------------------------------------------------------------------
# READ REPLICA CERTIFICATE TEMPLATES
#
# We have to produce the certificate outputs via template_file. Using splat syntax would yield:
# Resource 'google_sql_database_instance.read_replica' does not have attribute 'server_ca_cert.0.cert'
# for variable 'google_sql_database_instance.read_replica.*.server_ca_cert.0.cert'
# ------------------------------------------------------------------------------

data "template_file" "read_replica_certificate" {
  count    = "${var.num_read_replicas}"
  template = "${lookup(google_sql_database_instance.read_replica.server_ca_cert[count.index], "cert")}"
}

data "template_file" "read_replica_certificate_common_name" {
  count    = "${var.num_read_replicas}"
  template = "${lookup(google_sql_database_instance.read_replica.server_ca_cert[count.index], "common_name")}"
}

data "template_file" "read_replica_certificate_create_time" {
  count    = "${var.num_read_replicas}"
  template = "${lookup(google_sql_database_instance.read_replica.server_ca_cert[count.index], "create_time")}"
}

data "template_file" "read_replica_certificate_expiration_time" {
  count    = "${var.num_read_replicas}"
  template = "${lookup(google_sql_database_instance.read_replica.server_ca_cert[count.index], "expiration_time")}"
}

data "template_file" "read_replica_certificate_sha1_fingerprint" {
  count    = "${var.num_read_replicas}"
  template = "${lookup(google_sql_database_instance.read_replica.server_ca_cert[count.index], "sha1_fingerprint")}"
}
