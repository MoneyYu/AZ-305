resource "azurerm_storage_account" "lab02b" {
  name                     = "${local.lab02a_name}stor${local.random_str}"
  resource_group_name      = azurerm_resource_group.az305.name
  location                 = azurerm_resource_group.az305.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_batch_account" "lab02b" {
  name                                = "${local.lab02a_name}batch${local.random_str}"
  resource_group_name                 = azurerm_resource_group.az305.name
  location                            = azurerm_resource_group.az305.location
  storage_account_id                  = azurerm_storage_account.lab02b.id
  storage_account_authentication_mode = "StorageKeys"

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_batch_pool" "lab02b" {
  name                = "${local.lab02a_name}-batch-pool-${local.random_str}"
  resource_group_name = azurerm_resource_group.az305.name
  account_name        = azurerm_batch_account.lab02b.name
  display_name        = "${local.lab02a_name}-batch-pool-${local.random_str}"
  vm_size             = local.vm_size
  node_agent_sku_id   = "batch.node.ubuntu 20.04"

  auto_scale {
    evaluation_interval = "PT15M"

    formula = <<EOF
      startingNumberOfVMs = 1;
      maxNumberofVMs = 5;
      pendingTaskSamplePercent = $PendingTasks.GetSamplePercent(180 * TimeInterval_Second);
      pendingTaskSamples = pendingTaskSamplePercent < 70 ? startingNumberOfVMs : avg($PendingTasks.GetSample(180 *   TimeInterval_Second));
      $TargetDedicatedNodes=min(maxNumberofVMs, pendingTaskSamples);
EOF

  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }
}

resource "azurerm_batch_job" "lab02b" {
  name          = "${local.lab02a_name}-batch-job-${local.random_str}"
  batch_pool_id = azurerm_batch_pool.lab02b.id
}
