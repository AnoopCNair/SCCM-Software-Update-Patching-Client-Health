Declare @__timezoneoffset int select @__timezoneoffset = DateDiff(ss,getutcdate(),getdate());
SELECT v_R_System.Name0, v_R_System.Active0, v_R_System.Obsolete0, v_R_System.Client_Version0,
v_GS_WORKSTATION_STATUS.LastHWScan as 'Last Hardware Inventory', 
v_GS_LastSoftwareScan.LastScanDate as 'Last Software Inventory', 
LastHeartbeat=(select top 1 DATEADD(ss,@__timezoneoffset,AgentTime) from v_AgentDiscoveries where AgentName = 'Heartbeat Discovery' 
and v_AgentDiscoveries.ResourceID = v_R_System.ResourceID  order by AgentTime desc),
DATEADD(ss,@__timezoneoffset,htmd1.LastScanTime) as 'Last Scan Time',
htmd1.LastScanPackageLocation as 'Last Scan Package Location', 
htmd1.LastScanPackageVersion as 'Last Scan Package Version', 
htmd3.StateName as Status, 
Convert(VarChar(10), htmd4.LastBootUpTime0, 101) 'Last Boot Date', 
DateDiff(D, htmd4.LastBootUpTime0, GetDate()) 'Last Boot (Days)'
FROM v_R_System LEFT JOIN v_GS_WORKSTATION_STATUS ON v_R_System.ResourceID = v_GS_WORKSTATION_STATUS.ResourceID 
LEFT JOIN v_GS_LastSoftwareScan ON v_R_System.ResourceID = v_GS_LastSoftwareScan.ResourceID 
LEFT JOIN v_UpdateScanStatus htmd1 on v_R_System.ResourceID = htmd1.ResourceID 
LEFT JOIN v_StateNames htmd3 on htmd3.TopicType = 501 and htmd3.StateID = 
(case when (isnull(htmd1.LastScanState, 0)=0 and Left(isnull(v_R_System.Client_Version0, '4.0'), 1)<'4') 
then 7 else isnull(htmd1.LastScanState, 0) end) 
LEFT JOIN v_Gs_Operating_System htmd4 on v_R_System.ResourceID = htmd4.ResourceID 
LEFT JOIN v_FullCollectionMembership htmd2 on v_R_System.ResourceID = htmd2.ResourceID
where CollectionID='MEM00014'
order by v_R_System.Name0