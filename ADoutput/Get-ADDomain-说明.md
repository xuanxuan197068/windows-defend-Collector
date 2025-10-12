# Get-ADDomain 参数说明

## AllowedDNSSuffixes（允许的 DNS 后缀）
- **当前值**: `{}`（空）
- **说明**: 允许的 DNS 后缀列表，通常为空，除非域配置了额外的 DNS 后缀。

## ChildDomains（子域）
- **当前值**: `{}`（空）
- **说明**: 当前域的子域列表。如果域没有子域，则为空。

## ComputersContainer（计算机容器）
- **当前值**: `CN=Computers,DC=rd,DC=com`
- **说明**: 默认的计算机对象容器的 Distinguished Name (DN)。这是新加入域的计算机账户默认存放的位置。

## DeletedObjectsContainer（已删除对象容器）
- **当前值**: `CN=Deleted Objects,DC=rd,DC=com`
- **说明**: 存储被删除对象的容器的 DN。被删除的对象会暂时存储在此容器中，直到垃圾回收机制清理它们。

## DistinguishedName（可分辨名称）
- **当前值**: `DC=rd,DC=com`
- **说明**: 当前域的 DN，表示域在目录树中的唯一位置。

## DNSRoot（DNS 根名称）
- **当前值**: `rd.com`
- **说明**: 当前域的 DNS 名称。

## DomainControllersContainer（域控制器容器）
- **当前值**: `OU=Domain Controllers,DC=rd,DC=com`
- **说明**: 默认的域控制器对象容器的 DN。域控制器账户默认存放在此容器中。

## DomainMode（域功能级别）
- **当前值**: `Windows2012Domain`
- **说明**: 当前域的功能级别。例如，Windows2012Domain 表示域功能级别为 Windows Server 2012。

## DomainSID（域安全标识符）
- **当前值**: `S-1-5-21-3438909164-4223864119-2367268561`
- **说明**: 当前域的安全标识符 (SID)，用于唯一标识域。

## ForeignSecurityPrincipalsContainer（外部安全主体容器）
- **当前值**: `CN=ForeignSecurityPrincipals,DC=rd,DC=com`
- **说明**: 存储外部安全主体（如信任域中的用户或组）的容器的 DN。

## Forest（林）
- **当前值**: `rd.com`
- **说明**: 当前域所属的林的 DNS 名称。

## InfrastructureMaster（基础结构主机）
- **当前值**: `WIN-13L1MQMKNIO.rd.com`
- **说明**: 当前域的基础结构主机角色所在的域控制器。

## LastLogonReplicationInterval（最后登录复制间隔）
- **当前值**: （空）
- **说明**: 最后一次登录时间的复制间隔。如果未配置，则为空。

## LinkedGroupPolicyObjects（链接的组策略对象）
- **当前值**: `{CN={31B2F340-016D-11D2-945F-00C04FB984F9},CN=Policies,CN=System,DC=rd,DC=com}`
- **说明**: 链接到当前域的组策略对象 (GPO) 列表。

## LostAndFoundContainer（丢失和找到容器）
- **当前值**: `CN=LostAndFound,DC=rd,DC=com`
- **说明**: 存储丢失和找到的对象的容器的 DN。这些对象通常是由于复制问题导致的。

## ManagedBy（管理者）
- **当前值**: （空）
- **说明**: 当前域的管理者信息。如果未设置，则为空。

## Name（名称）
- **当前值**: `rd`
- **说明**: 当前域的名称。

## NetBIOSName（NetBIOS 名称）
- **当前值**: `RD`
- **说明**: 当前域的 NetBIOS 名称，通常是域名的简短版本。

## ObjectClass（对象类）
- **当前值**: `domainDNS`
- **说明**: 当前域对象的类类型，通常为 domainDNS。

## ObjectGUID（对象 GUID）
- **当前值**: `af9d3171-4ac9-4002-afeb-f96036e0912c`
- **说明**: 当前域对象的全局唯一标识符 (GUID)。

## ParentDomain（父域）
- **当前值**: （空）
- **说明**: 当前域的父域。如果域是根域，则为空。

## PDCEmulator（PDC 模拟器）
- **当前值**: `WIN-13L1MQMKNIO.rd.com`
- **说明**: 当前域的主域控制器 (PDC) 模拟器角色所在的域控制器。

## PublicKeyRequiredPasswordRolling（公钥密码轮换）
- **当前值**: （空）
- **说明**: 指示是否需要公钥密码轮换。如果未配置，则为空。

## QuotasContainer（配额容器）
- **当前值**: `CN=NTDS Quotas,DC=rd,DC=com`
- **说明**: 存储配额信息的容器的 DN。

## ReadOnlyReplicaDirectoryServers（只读副本域控制器）
- **当前值**: `{}`（空）
- **说明**: 当前域的只读域控制器 (RODC) 列表。如果没有 RODC，则为空。

## ReplicaDirectoryServers（副本域控制器）
- **当前值**: `{WIN-13L1MQMKNIO.rd.com, Win2016辅助域控.rd.com}`
- **说明**: 当前域的所有域控制器列表。

## RIDMaster（RID 主机）
- **当前值**: `WIN-13L1MQMKNIO.rd.com`
- **说明**: 当前域的相对标识符 (RID) 主机角色所在的域控制器。

## SubordinateReferences（下级引用）
- **当前值**: `{DC=ForestDnsZones,DC=rd,DC=com, DC=DomainDnsZones,DC=rd,DC=com, CN=Configuration,DC=rd,DC=com}`
- **说明**: 当前域的下级引用列表，通常包括林的配置分区和 DNS 分区。

## SystemsContainer（系统容器）
- **当前值**: `CN=System,DC=rd,DC=com`
- **说明**: 存储系统级对象（如默认组策略对象）的容器的 DN。

## UsersContainer（用户容器）
- **当前值**: `CN=Users,DC=rd,DC=com`
- **说明**: 默认的用户对象容器的 DN。新创建的用户账户默认存放在此容器中。
