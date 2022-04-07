declare @__timezoneoffset int select @__timezoneoffset = DateDiff(ss,getutcdate(),getdate());
SELECT v_R_System.Name0, v_R_System.Active0, v_R_System.Obsolete0, v_R_System.Client_Version0,
v_GS_WORKSTATION_STATUS.LastHWScan as LastHardwareInventory, 
v_GS_LastSoftwareScan.LastScanDate as LastSoftwareInventory, 
LastHeartbeat=(select top 1 DATEADD(ss,@__timezoneoffset,AgentTime) from v_AgentDiscoveries where AgentName = 'Heartbeat Discovery' and v_AgentDiscoveries.ResourceID = v_R_System.ResourceID  order by AgentTime desc),
DATEADD(ss,@__timezoneoffset,uss.LastScanTime) as LastScanTime,
uss.LastScanPackageLocation as LastScanPackageLocation, 
uss.LastScanPackageVersion as LastScanPackageVersion, 
sn.StateName as Status, 
Convert(VarChar(10), OS.LastBootUpTime0, 101) 'Last Boot Date', 
DateDiff(D, OS.LastBootUpTime0, GetDate()) 'Last Boot (Days)'
FROM v_R_System LEFT JOIN v_GS_WORKSTATION_STATUS ON v_R_System.ResourceID = v_GS_WORKSTATION_STATUS.ResourceID 
LEFT JOIN v_GS_LastSoftwareScan ON v_R_System.ResourceID = v_GS_LastSoftwareScan.ResourceID 
LEFT JOIN v_UpdateScanStatus uss on v_R_System.ResourceID = uss.ResourceID 
LEFT JOIN v_StateNames sn on sn.TopicType = 501 and sn.StateID = (case when (isnull(uss.LastScanState, 0)=0 and Left(isnull(v_R_System.Client_Version0, '4.0'), 1)<'4') then 7 else isnull(uss.LastScanState, 0) end) 
LEFT JOIN v_Gs_Operating_System OS on v_R_System.ResourceID = OS.ResourceID 
LEFT JOIN v_FullCollectionMembership fcm on v_R_System.ResourceID = fcm.ResourceID
order by v_R_System.Name0