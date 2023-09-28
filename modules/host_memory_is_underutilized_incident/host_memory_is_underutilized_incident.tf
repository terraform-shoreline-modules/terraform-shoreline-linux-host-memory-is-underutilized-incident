resource "shoreline_notebook" "host_memory_is_underutilized_incident" {
  name       = "host_memory_is_underutilized_incident"
  data       = file("${path.module}/data/host_memory_is_underutilized_incident.json")
  depends_on = [shoreline_action.invoke_memory_status,shoreline_action.invoke_decrease_memory_allocation]
}

resource "shoreline_file" "memory_status" {
  name             = "memory_status"
  input_file       = "${path.module}/data/memory_status.sh"
  md5              = filemd5("${path.module}/data/memory_status.sh")
  description      = "The server may be overprovisioned with more memory than required for the workload it is running."
  destination_path = "/agent/scripts/memory_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "decrease_memory_allocation" {
  name             = "decrease_memory_allocation"
  input_file       = "${path.module}/data/decrease_memory_allocation.sh"
  md5              = filemd5("${path.module}/data/decrease_memory_allocation.sh")
  description      = "Decrease memory allocation: Allocate less memory to the host vm to ensure that it does not have too much unused memory."
  destination_path = "/agent/scripts/decrease_memory_allocation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_memory_status" {
  name        = "invoke_memory_status"
  description = "The server may be overprovisioned with more memory than required for the workload it is running."
  command     = "`chmod +x /agent/scripts/memory_status.sh && /agent/scripts/memory_status.sh`"
  params      = ["CONFIGURED_AMOUNT_OF_MEMORY"]
  file_deps   = ["memory_status"]
  enabled     = true
  depends_on  = [shoreline_file.memory_status]
}

resource "shoreline_action" "invoke_decrease_memory_allocation" {
  name        = "invoke_decrease_memory_allocation"
  description = "Decrease memory allocation: Allocate less memory to the host vm to ensure that it does not have too much unused memory."
  command     = "`chmod +x /agent/scripts/decrease_memory_allocation.sh && /agent/scripts/decrease_memory_allocation.sh`"
  params      = ["HOST_VM_NAME","DECREASED_MEMORY_SIZE"]
  file_deps   = ["decrease_memory_allocation"]
  enabled     = true
  depends_on  = [shoreline_file.decrease_memory_allocation]
}

