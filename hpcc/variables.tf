variable "owner" {
  description = "Information for the user who administers the deployment."
  type = object({
    name  = string
    email = string
  })

  validation {
    condition = try(
      regex("hpccdemo", var.owner.name) != "hpccdemo", true
      ) && try(
      regex("hpccdemo", var.owner.email) != "hpccdemo", true
      ) && try(
      regex("@example.com", var.owner.email) != "@example.com", true
    )
    error_message = "Your name and email are required in the owner block and must not contain hpccdemo or @example.com."
  }
}

variable "azure_auth" {
  description = "Azure authentication"
  type = object({
    AAD_CLIENT_ID     = optional(string)
    AAD_CLIENT_SECRET = optional(string)
    AAD_TENANT_ID     = optional(string)
    AAD_OBJECT_ID     = optional(string)
    SUBSCRIPTION_ID   = string
  })

  nullable = false
}

variable "expose_services" {
  description = "Make HPCC services accessible through the internet."
  type = object({
    eclwatch   = bool
    eclqueries = bool
  })
  default = {
    eclqueries = false
    eclwatch   = true
  }
}

variable "auto_launch_services" {
  description = "Auto launch HPCC services."
  type = object({
    eclwatch   = bool
    eclqueries = bool
  })
  default = {
    eclwatch   = false
    eclqueries = false
  }
}

variable "auto_connect" {
  description = "Automatically connect to the Kubernetes cluster from the host machine by overwriting the current context."
  type        = bool
  default     = false
}

variable "disable_naming_conventions" {
  description = "Naming convention module."
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Metadata module variables."
  type = object({
    market              = string
    sre_team            = string
    environment         = string
    product_name        = string
    business_unit       = string
    product_group       = string
    subscription_type   = string
    resource_group_type = string
    project             = string
    additional_tags     = map(string)
    location            = string
  })

  default = {
    business_unit       = ""
    environment         = ""
    market              = ""
    product_group       = ""
    product_name        = "hpcc"
    project             = ""
    resource_group_type = ""
    sre_team            = ""
    subscription_type   = ""
    additional_tags     = {}
    location            = ""
  }
}

variable "use_existing_vnet" {
  description = "Information about the existing VNet to use. Overrides vnet variable."
  type = object({
    name                = string
    resource_group_name = string
    route_table_name    = string
    location            = string

    subnets = object({
      aks = object({
        name = string
      })
    })
  })

  default = null
}

## HPCC Helm Release
#######################
variable "hpcc_enabled" {
  description = "Is HPCC Platform deployment enabled?"
  type        = bool
  default     = true
}

variable "hpcc_namespace" {
  description = "Kubernetes namespace where resources will be created."
  type = object({
    existing_namespace = optional(string)
    labels             = optional(map(string), { name = "hpcc" })
    create_namespace   = optional(bool, true)
  })
  default = {}
}

variable "helm_chart_strings_overrides" {
  description = "Helm chart values as strings, in yaml format, to be merged last."
  type        = list(string)
  default     = []
}

variable "helm_chart_files_overrides" {
  description = "Helm chart values files, in yaml format, to be merged."
  type        = list(string)
  default     = []
}

variable "helm_chart_version" {
  description = "Version of the HPCC Helm Chart to use."
  type        = string
  default     = null
}

variable "helm_chart_timeout" {
  description = "Helm timeout for hpcc chart."
  type        = number
  default     = 300
}

variable "hpcc_container" {
  description = "HPCC container information (if version is set to null helm chart version is used)."
  type = object({
    image_name = optional(string, "platform-core")
    image_root = optional(string, "hpccsystems")
    version    = optional(string, "latest")
  })

  default = {
    image_name           = "platform-core"
    image_root           = "hpccsystems"
    version              = "latest"
    custom_chart_version = null
    custom_image_version = null
  }
}

variable "hpcc_container_registry_auth" {
  description = "Registry authentication for HPCC container."
  type = object({
    password = string
    username = string
  })
  default   = null
  sensitive = true
}

variable "node_tuning_containers" {
  description = "URIs for containers to be used by node tuning submodule."
  type = object({
    busybox = string
    debian  = string
  })
  default = null
}

variable "enable_node_tuning" {
  description = "Enable node tuning daemonset (only needed once per AKS cluster)."
  type        = bool
  default     = false
}

variable "vault_config" {
  description = "Input for vault secrets."
  type = object({
    git = optional(map(object({
      name            = optional(string)
      url             = optional(string)
      kind            = optional(string)
      vault_namespace = optional(string)
      role_id         = optional(string)
      secret_name     = optional(string) # Should match the secret name created in the corresponding vault_secrets variable
    }))),
    ecl = optional(map(object({
      name            = optional(string)
      url             = optional(string)
      kind            = optional(string)
      vault_namespace = optional(string)
      role_id         = optional(string)
      secret_name     = optional(string) # Should match the secret name created in the corresponding vault_secrets variable
    }))),
    ecluser = optional(map(object({
      name            = optional(string)
      url             = optional(string)
      kind            = optional(string)
      vault_namespace = optional(string)
      role_id         = optional(string)
      secret_name     = optional(string) # Should match the secret name created in the corresponding vault_secrets variable
    }))),
    esp = optional(map(object({
      name            = optional(string)
      url             = optional(string)
      kind            = optional(string)
      vault_namespace = optional(string)
      role_id         = optional(string)
      secret_name     = optional(string) # Should match the secret name created in the corresponding vault_secrets variable
    })))
  })
  default = {}
}

## Roxie Config
##################
variable "roxie_config" {
  description = "Configuration for Roxie(s)."
  type = list(object({
    disabled                       = optional(bool, true)
    name                           = optional(string, "roxie")
    nodeSelector                   = optional(map(string), { workload = "roxiepool" })
    numChannels                    = optional(number, 2)
    prefix                         = optional(string, "roxie")
    replicas                       = optional(number, 2)
    serverReplicas                 = optional(number, 0)
    acePoolSize                    = optional(number, 6)
    actResetLogPeriod              = optional(number, 0)
    affinity                       = optional(number, 0)
    allFilesDynamic                = optional(bool, false)
    blindLogging                   = optional(bool, false)
    blobCacheMem                   = optional(number, 0)
    callbackRetries                = optional(number, 3)
    callbackTimeout                = optional(number, 500)
    checkCompleted                 = optional(bool, true)
    checkFileDate                  = optional(bool, false)
    checkPrimaries                 = optional(bool, true)
    clusterWidth                   = optional(number, 1)
    copyResources                  = optional(bool, true)
    coresPerQuery                  = optional(number, 0)
    crcResources                   = optional(bool, false)
    dafilesrvLookupTimeout         = optional(number, 10000)
    debugPermitted                 = optional(bool, true)
    defaultConcatPreload           = optional(number, 0)
    defaultFetchPreload            = optional(number, 0)
    defaultFullKeyedJoinPreload    = optional(number, 0)
    defaultHighPriorityTimeLimit   = optional(number, 0)
    defaultHighPriorityTimeWarning = optional(number, 30000)
    defaultKeyedJoinPreload        = optional(number, 0)
    defaultLowPriorityTimeLimit    = optional(number, 0)
    defaultLowPriorityTimeWarning  = optional(number, 90000)
    defaultMemoryLimit             = optional(number, 1073741824)
    defaultParallelJoinPreload     = optional(number, 0)
    defaultPrefetchProjectPreload  = optional(number, 10)
    defaultSLAPriorityTimeLimit    = optional(number, 0)
    defaultSLAPriorityTimeWarning  = optional(number, 30000)
    defaultStripLeadingWhitespace  = optional(bool, false)
    diskReadBufferSize             = optional(number, 65536)
    doIbytiDelay                   = optional(bool, true)
    egress                         = optional(string, "engineEgress")
    enableHeartBeat                = optional(bool, false)
    enableKeyDiff                  = optional(bool, false)
    enableSysLog                   = optional(bool, false)
    fastLaneQueue                  = optional(bool, true)
    fieldTranslationEnabled        = optional(string, "payload")
    flushJHtreeCacheOnOOM          = optional(bool, true)
    forceStdLog                    = optional(bool, false)
    highTimeout                    = optional(number, 2000)
    ignoreMissingFiles             = optional(bool, false)
    indexReadChunkSize             = optional(number, 60000)
    initIbytiDelay                 = optional(number, 10)
    jumboFrames                    = optional(bool, false)
    lazyOpen                       = optional(bool, true)
    leafCacheMem                   = optional(number, 500)
    linuxYield                     = optional(bool, false)
    localFilesExpire               = optional(number, 1)
    localSlave                     = optional(bool, false)
    logFullQueries                 = optional(bool, false)
    logQueueDrop                   = optional(number, 32)
    logQueueLen                    = optional(number, 512)
    lowTimeout                     = optional(number, 10000)
    maxBlockSize                   = optional(number, 1000000000)
    maxHttpConnectionRequests      = optional(number, 1)
    maxLocalFilesOpen              = optional(number, 4000)
    maxLockAttempts                = optional(number, 5)
    maxRemoteFilesOpen             = optional(number, 100)
    memTraceLevel                  = optional(number, 1)
    memTraceSizeLimit              = optional(number, 0)
    memoryStatsInterval            = optional(number, 60)
    minFreeDiskSpace               = optional(number, 6442450944)
    minIbytiDelay                  = optional(number, 2)
    minLocalFilesOpen              = optional(number, 2000)
    minRemoteFilesOpen             = optional(number, 50)
    miscDebugTraceLevel            = optional(number, 0)
    monitorDaliFileServer          = optional(bool, false)
    nodeCacheMem                   = optional(number, 1000)
    nodeCachePreload               = optional(bool, false)
    parallelAggregate              = optional(number, 0)
    parallelLoadQueries            = optional(number, 1)
    perChannelFlowLimit            = optional(number, 50)
    pingInterval                   = optional(number, 0)
    preabortIndexReadsThreshold    = optional(number, 100)
    preabortKeyedJoinsThreshold    = optional(number, 100)
    preloadOnceData                = optional(bool, true)
    prestartSlaveThreads           = optional(bool, false)
    remoteFilesExpire              = optional(number, 3600)
    roxieMulticastEnabled          = optional(bool, false)
    serverSideCacheSize            = optional(number, 0)
    serverThreads                  = optional(number, 100)
    simpleLocalKeyedJoins          = optional(bool, true)
    sinkMode                       = optional(string, "sequential")
    slaTimeout                     = optional(number, 2000)
    slaveConfig                    = optional(string, "simple")
    slaveThreads                   = optional(number, 30)
    soapTraceLevel                 = optional(number, 1)
    socketCheckInterval            = optional(number, 5000)
    statsExpiryTime                = optional(number, 3600)
    systemMonitorInterval          = optional(number, 60000)
    totalMemoryLimit               = optional(string, "5368709120")
    traceLevel                     = optional(number, 1)
    traceRemoteFiles               = optional(bool, false)
    trapTooManyActiveQueries       = optional(bool, true)
    udpAdjustThreadPriorities      = optional(bool, true)
    udpFlowAckTimeout              = optional(number, 10)
    udpFlowSocketsSize             = optional(number, 33554432)
    udpInlineCollation             = optional(bool, true)
    udpInlineCollationPacketLimit  = optional(number, 50)
    udpLocalWriteSocketSize        = optional(number, 16777216)
    udpMaxPermitDeadTimeouts       = optional(number, 100)
    udpMaxRetryTimedoutReqs        = optional(number, 10)
    udpMaxSlotsPerClient           = optional(number, 100)
    udpMulticastBufferSize         = optional(number, 33554432)
    udpOutQsPriority               = optional(number, 5)
    udpQueueSize                   = optional(number, 1000)
    udpRecvFlowTimeout             = optional(number, 2000)
    udpRequestToSendAckTimeout     = optional(number, 500)
    udpResendTimeout               = optional(number, 100)
    udpRequestToSendTimeout        = optional(number, 2000)
    udpResendEnabled               = optional(bool, true)
    udpRetryBusySenders            = optional(number, 0)
    udpSendCompletedInData         = optional(bool, false)
    udpSendQueueSize               = optional(number, 500)
    udpSnifferEnabled              = optional(bool, false)
    udpTraceLevel                  = optional(number, 0)
    useAeron                       = optional(bool, false)
    useDynamicServers              = optional(bool, false)
    useHardLink                    = optional(bool, false)
    useLogQueue                    = optional(bool, true)
    useMemoryMappedIndexes         = optional(bool, false)
    useRemoteResources             = optional(bool, false)
    useTreeCopy                    = optional(bool, false)
    services = optional(list(object({
      name        = optional(string, "roxie")
      servicePort = optional(number, 9876)
      listenQueue = optional(number, 200)
      numThreads  = optional(number, 30)
      visibility  = optional(string, "local")
      annotations = optional(map(string), {})
      })),
      [
        {
          name        = "roxie"
          servicePort = 9876
          listenQueue = 200
          numThreads  = 30
          visibility  = "local"
          annotations = {}
        }
      ]
    )
    topoServer = optional(object({
      replicas = optional(number, 1)
      }),
      {
        replicas = 1
      }
    )
    channelResources = optional(object({
      cpu    = optional(string, "1")
      memory = optional(string, "4G")
      }),
      {
        cpu    = "1"
        memory = "4G"
      }
    )
    resources = optional(object({
      cpu    = optional(string, "1")
      memory = optional(string, "4G")
      }),
      {
        cpu    = "1"
        memory = "4G"
      }
    )
  }))

  default = [{}]
}

## Thor Config
##################
variable "thor_config" {
  description = "Configurations for Thor."
  type = list(object(
    {
      disabled = bool
      eclAgentResources = optional(object({
        cpu    = string
        memory = string
        }
        ),
        {
          cpu    = 1
          memory = "2G"
      })
      keepJobs = optional(string, "none")
      managerResources = optional(object({
        cpu    = string
        memory = string
        }),
        {
          cpu    = 1
          memory = "2G"
      })
      maxGraphs           = optional(number, 2)
      maxJobs             = optional(number, 4)
      maxGraphStartupTime = optional(number, 172800)
      name                = optional(string, "thor")
      nodeSelector        = optional(map(string), { workload = "thorpool" })
      numWorkers          = optional(number, 2)
      numWorkersPerPod    = optional(number, 1)
      prefix              = optional(string, "thor")
      egress              = optional(string, "engineEgress")
      tolerations_value   = optional(string, "thorpool")
      workerMemory = optional(object({
        query      = string
        thirdParty = string
        }),
        {
          query      = "3G"
          thirdParty = "500M"
      })
      workerResources = optional(object({
        cpu    = string
        memory = string
        }),
        {
          cpu    = 3
          memory = "4G"
      })
      cost = object({
        perCpu = number
      })
  }))

  default = null
}

## ECL Agent Config
#######################
variable "eclagent_settings" {
  description = "eclagent settings"
  type = map(object({
    replicas          = number
    maxActive         = number
    prefix            = string
    use_child_process = bool
    spillPlane        = optional(string, "spill")
    type              = string
    resources = object({
      cpu    = string
      memory = string
    })
    cost = object({
      perCpu = number
    })
    egress = optional(string)
  }))

  default = {
    hthor = {
      replicas          = 1
      maxActive         = 4
      prefix            = "hthor"
      use_child_process = false
      type              = "hthor"
      spillPlane        = "spill"
      resources = {
        cpu    = "1"
        memory = "4G"
      }
      egress = "engineEgress"
      cost = {
        perCpu = 1
      }
    },
  }
}

## ECLCCServer Config
########################
variable "eclccserver_settings" {
  description = "Set cpu and memory values of the eclccserver. Toggle use_child_process to true to enable eclccserver child processes."
  type = map(object({
    useChildProcesses  = optional(bool, false)
    replicas           = optional(number, 1)
    maxActive          = optional(number, 4)
    egress             = optional(string, "engineEgress")
    gitUsername        = optional(string, "")
    defaultRepo        = optional(string, "")
    defaultRepoVersion = optional(string, "")
    resources = optional(object({
      cpu    = string
      memory = string
    }))
    cost = object({
      perCpu = number
    })
    listen_queue          = optional(list(string), [])
    childProcessTimeLimit = optional(number, 10)
    legacySyntax          = optional(bool, false)
    options = optional(list(object({
      name  = string
      value = string
    })))
  }))

  default = {
    "myeclccserver" = {
      useChildProcesses     = false
      maxActive             = 4
      egress                = "engineEgress"
      replicas              = 1
      childProcessTimeLimit = 10
      resources = {
        cpu    = "1"
        memory = "4G"
      }
      legacySyntax = false
      options      = []
      cost = {
        perCpu = 1
      }
  } }
}

## Dali Config
##################
variable "dali_settings" {
  description = "dali settings"
  type = object({
    coalescer = object({
      interval     = number
      at           = string
      minDeltaSize = number
      resources = object({
        cpu    = string
        memory = string
      })
    })
    resources = object({
      cpu    = string
      memory = string
    })
    maxStartupTime = number
  })

  default = {
    coalescer = {
      interval     = 24
      at           = "* * * * *"
      minDeltaSize = 50000
      resources = {
        cpu    = "1"
        memory = "4G"
      }
    }
    resources = {
      cpu    = "2"
      memory = "8G"
    }
    maxStartupTime = 1200
  }
}

## DFU Server Config
########################
variable "dfuserver_settings" {
  description = "DFUServer settings"
  type = object({
    maxJobs = number
    resources = object({
      cpu    = string
      memory = string
    })
  })

  default = {
    maxJobs = 3
    resources = {
      cpu    = "1"
      memory = "2G"
    }
  }
}

## Spray Service Config
#########################
variable "spray_service_settings" {
  description = "spray services settings"
  type = object({
    replicas     = number
    nodeSelector = string
  })

  default = {
    replicas     = 3
    nodeSelector = "servpool" #"spraypool"
  }
}

## Sasha Config
##################
variable "sasha_config" {
  description = "Configuration for Sasha."
  type = object({
    disabled = bool
    wu-archiver = object({
      disabled = bool
      service = object({
        servicePort = number
      })
      plane           = string
      interval        = number
      limit           = number
      cutoff          = number
      backup          = number
      at              = string
      throttle        = number
      retryinterval   = number
      keepResultFiles = bool
      # egress          = string
    })

    dfuwu-archiver = object({
      disabled = bool
      service = object({
        servicePort = number
      })
      plane    = string
      interval = number
      limit    = number
      cutoff   = number
      at       = string
      throttle = number
      # egress   = string
    })

    dfurecovery-archiver = object({
      disabled = bool
      interval = number
      limit    = number
      cutoff   = number
      at       = string
      # egress   = string
    })

    file-expiry = object({
      disabled             = bool
      interval             = number
      at                   = string
      persistExpiryDefault = number
      expiryDefault        = number
      user                 = string
      # egress               = string
    })
  })

  default = {
    disabled = false
    wu-archiver = {
      disabled = false
      service = {
        servicePort = 8877
      }
      plane           = "sasha"
      interval        = 6
      limit           = 400
      cutoff          = 3
      backup          = 0
      at              = "* * * * *"
      throttle        = 0
      retryinterval   = 6
      keepResultFiles = false
      # egress          = "engineEgress"
    }

    dfuwu-archiver = {
      disabled = false
      service = {
        servicePort = 8877
      }
      plane    = "sasha"
      interval = 24
      limit    = 100
      cutoff   = 14
      at       = "* * * * *"
      throttle = 0
      # egress   = "engineEgress"
    }

    dfurecovery-archiver = {
      disabled = false
      interval = 12
      limit    = 20
      cutoff   = 4
      at       = "* * * * *"
      # egress   = "engineEgress"
    }

    file-expiry = {
      disabled             = false
      interval             = 1
      at                   = "* * * * *"
      persistExpiryDefault = 7
      expiryDefault        = 4
      user                 = "sasha"
      # egress               = "engineEgress"
    }
  }
}

## LDAP Config
##################
variable "ldap_config" {
  description = "LDAP settings for dali and esp services."
  type = object({
    dali = object({
      adminGroupName      = string
      filesBasedn         = string
      groupsBasedn        = string
      hpcc_admin_password = string
      hpcc_admin_username = string
      ldap_admin_password = string
      ldap_admin_username = string
      ldapAdminVaultId    = string
      resourcesBasedn     = string
      sudoersBasedn       = string
      systemBasedn        = string
      usersBasedn         = string
      workunitsBasedn     = string
      ldapCipherSuite     = string
    })
    esp = object({
      adminGroupName      = string
      filesBasedn         = string
      groupsBasedn        = string
      ldap_admin_password = string
      ldap_admin_username = string
      ldapAdminVaultId    = string
      resourcesBasedn     = string
      sudoersBasedn       = string
      systemBasedn        = string
      usersBasedn         = string
      workunitsBasedn     = string
      ldapCipherSuite     = string
    })
    ldap_server = string
  })

  default   = null
  sensitive = true
}

variable "ldap_tunables" {
  description = "Tunable settings for LDAP."
  type = object({
    cacheTimeout                  = number
    checkScopeScans               = bool
    ldapTimeoutSecs               = number
    maxConnections                = number
    passwordExpirationWarningDays = number
    sharedCache                   = bool
  })

  default = {
    cacheTimeout                  = 5
    checkScopeScans               = false
    ldapTimeoutSecs               = 131
    maxConnections                = 10
    passwordExpirationWarningDays = 10
    sharedCache                   = true
  }
}

## Data Storage Config
#########################
variable "install_blob_csi_driver" {
  description = "Install blob-csi-drivers on the cluster."
  type        = bool
  default     = true
}

variable "spill_volumes" {
  description = "Map of objects to create Spill Volumes"
  type = map(object({
    name      = string # "Name of spill volume to be created."
    size      = number # "Size of spill volume to be created (in GB)."
    prefix    = string # "Prefix of spill volume to be created."
    host_path = string # "Host path on spill volume to be created."
    expert_settings = object({
      validatePlaneScript = list(string)
    })
  }))

  default = {
    "spill" = {
      name      = "spill"
      size      = 300
      prefix    = "/var/lib/HPCCSystems/spill"
      host_path = "/mnt"
      expert_settings = {
        validatePlaneScript = ["exit 0"]
      }
    }
  }
}

variable "data_storage_config" {
  description = "Data plane config for HPCC."
  type = object({
    internal = object({
      blob_nfs = object({
        data_plane_count = number
        storage_account_settings = object({
          # authorized_ip_ranges                 = map(string)
          delete_protection                    = bool
          replication_type                     = string
          subnet_ids                           = map(string)
          blob_soft_delete_retention_days      = optional(number)
          container_soft_delete_retention_days = optional(number)
        })
      })
      netapp_volumes = object({
        use_as_index_build_plane = bool
        plane_name               = string
        netapp_account = optional(object({
          ad_dns_servers         = list(string)
          ad_domain_name         = string
          smb_server_name        = string
          ad_admin_username      = string
          ad_admin_password      = string
          ad_organizational_unit = string
        }))
        netapp_capacity_pool = optional(object({
          service_level = string
          size_in_tb    = number
          qos_type      = string
        }))
        netapp_volume_nfs = optional(object({
          volume_count        = number
          zone                = number
          path                = string
          service_level       = string
          subnet_id           = string
          storage_quota_in_gb = number
          allowed_clients     = list(string)
        }))
      })
      hpc_cache = object({
        cache_update_frequency = string
        dns = object({
          zone_name                = string
          zone_resource_group_name = string
        })
        resource_provider_object_id = string
        size                        = string
        storage_account_data_planes = list(object({
          container_id         = string
          container_name       = string
          id                   = number
          resource_group_name  = string
          storage_account_id   = string
          storage_account_name = string
        }))
        subnet_id = string
      })
    })
    external = object({
      blob_nfs = list(object({
        container_id         = string
        container_name       = string
        id                   = string
        resource_group_name  = string
        storage_account_id   = string
        storage_account_name = string
      }))
      hpc_cache = list(object({
        id     = string
        path   = string
        server = string
      }))
      hpcc = list(object({
        name = string
        planes = list(object({
          local  = string
          remote = string
        }))
        service = string
      }))
    })
  })
  default = {
    internal = {
      blob_nfs = {
        data_plane_count = 1
        storage_account_settings = {
          # authorized_ip_ranges                 = {}
          delete_protection                    = false
          replication_type                     = "ZRS"
          subnet_ids                           = {}
          blob_soft_delete_retention_days      = 7
          container_soft_delete_retention_days = 7
        }
      }
      hpc_cache      = null
      netapp_volumes = null
    }
    external = null
  }

  validation {
    condition = (var.data_storage_config.internal == null ? true :
      var.data_storage_config.internal.hpc_cache == null ? true :
    contains(["never", "30s", "3h"], var.data_storage_config.internal.hpc_cache.cache_update_frequency))
    error_message = "HPC Cache update frequency must be \"never\", \"30s\" or \"3h\"."
  }
}

variable "external_storage_accounts" {
  description = "External services storage config."
  type = list(object({
    category        = string
    container_name  = string
    path            = string
    plane_name      = string
    protocol        = string
    resource_group  = string
    size            = number
    storage_account = string
    storage_type    = string
    prefix_name     = string
  }))

  default = null
}

variable "remote_storage_plane" {
  description = "Input for attaching remote storage plane"
  type = map(object({
    dfs_service_name = string
    dfs_secret_name  = string
    target_storage_accounts = map(object({
      name   = string
      prefix = string
    }))
  }))

  default = null
}

variable "onprem_lz_settings" {
  description = "Input for allowing OnPrem LZ."
  type = map(object({
    prefix = string
    hosts  = list(string)
  }))

  default = {}
}

variable "admin_services_storage" {
  description = "PV sizes for admin service planes in gigabytes (storage billed only as consumed)."
  type = object({
    dali = object({
      size = number
      type = string
    })
    debug = object({
      size = number
      type = string
    })
    dll = object({
      size = number
      type = string
    })
    lz = object({
      size = number
      type = string
    })
    sasha = object({
      size = number
      type = string
    })
  })

  default = {
    dali = {
      size = 100
      type = "azurefiles"
    }
    debug = {
      size = 100
      type = "blobnfs"
    }
    dll = {
      size = 100
      type = "blobnfs"
    }
    lz = {
      size = 100
      type = "blobnfs"
    }
    sasha = {
      size = 100
      type = "blobnfs"
    }
  }

  validation {
    condition     = length([for k, v in var.admin_services_storage : v.type if !contains(["azurefiles", "blobnfs"], v.type)]) == 0
    error_message = "The type must be either \"azurefiles\" or \"blobnfs\"."
  }

  validation {
    condition     = length([for k, v in var.admin_services_storage : v.size if v.type == "azurefiles" && v.size < 100]) == 0
    error_message = "Size must be at least 100 for \"azurefiles\" type."
  }
}

variable "admin_services_storage_account_settings" {
  description = "Settings for admin services storage account."
  type = object({
    authorized_ip_ranges = optional(map(string))
    delete_protection    = bool
    replication_type     = string
    # subnet_ids                           = map(string)
    blob_soft_delete_retention_days      = optional(number)
    container_soft_delete_retention_days = optional(number)
    file_share_retention_days            = optional(number)
  })

  default = {
    authorized_ip_ranges                 = {}
    delete_protection                    = false
    replication_type                     = "ZRS"
    subnet_ids                           = {}
    blob_soft_delete_retention_days      = 7
    container_soft_delete_retention_days = 7
    file_share_retention_days            = 7
  }
}

variable "ignore_external_storage" {
  description = "Should storage created using the storage module or var.external_storage_config be ignored?"
  type        = bool
  default     = false
}

## Node Selector
####################
variable "admin_services_node_selector" {
  description = "Node selector for admin services pods."
  type        = map(map(string))
  default     = {}

  validation {
    condition = length([for service in keys(var.admin_services_node_selector) :
    service if !contains(["all", "dali", "esp", "eclagent", "eclccserver"], service)]) == 0
    error_message = "The keys must be one of \"all\", \"dali\", \"esp\", \"eclagent\" or \"eclccserver\"."
  }
}

## DNS
#########
variable "internal_domain" {
  description = "DNS Domain name"
  type        = string
  default     = null
}
