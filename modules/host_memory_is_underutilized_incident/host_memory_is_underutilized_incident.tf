resource "shoreline_notebook" "host_memory_is_underutilized_incident" {
  name       = "host_memory_is_underutilized_incident"
  data       = file("${path.module}/data/host_memory_is_underutilized_incident.json")
  depends_on = [shoreline_action.invoke_memory_analysis,shoreline_action.invoke_decrease_vm_memory]
}

resource "shoreline_file" "memory_analysis" {
  name             = "memory_analysis"
  input_file       = "${path.module}/data/memory_analysis.sh"
  md5              = filemd5("${path.module}/data/memory_analysis.sh")
  description      = "The server may be overprovisioned with more memory than required for the workload it is running."
  destination_path = "/agent/scripts/memory_analysis.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "decrease_vm_memory" {
  name             = "decrease_vm_memory"
  input_file       = "${path.module}/data/decrease_vm_memory.sh"
  md5              = filemd5("${path.module}/data/decrease_vm_memory.sh")
  description      = "Decrease memory allocation: Allocate less memory to the host vm to ensure that it does not have too much unused memory."
  destination_path = "/agent/scripts/decrease_vm_memory.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_memory_analysis" {
  name        = "invoke_memory_analysis"
  description = "The server may be overprovisioned with more memory than required for the workload it is running."
  command     = "`chmod +x /agent/scripts/memory_analysis.sh && /agent/scripts/memory_analysis.sh`"
  params      = ["CONFIGURED_AMOUNT_OF_MEMORY"]
  file_deps   = ["memory_analysis"]
  enabled     = true
  depends_on  = [shoreline_file.memory_analysis]
}

resource "shoreline_action" "invoke_decrease_vm_memory" {
  name        = "invoke_decrease_vm_memory"
  description = "Decrease memory allocation: Allocate less memory to the host vm to ensure that it does not have too much unused memory."
  command     = "`chmod +x /agent/scripts/decrease_vm_memory.sh && /agent/scripts/decrease_vm_memory.sh`"
  params      = ["DECREASED_MEMORY_SIZE","HOST_VM_NAME"]
  file_deps   = ["decrease_vm_memory"]
  enabled     = true
  depends_on  = [shoreline_file.decrease_vm_memory]
}

