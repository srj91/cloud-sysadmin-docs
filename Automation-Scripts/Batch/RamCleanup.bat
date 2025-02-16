@Echo Off

REM Title - Clearing RAM
C:
cd "C:\EmptyRAM"
Echo Clearing your RAM
Echo ======================================== 
Echo Emptying Standby List
Echo ========================================
RAMMap.exe -Et

Echo ========================================
Echo Emptying Working Sets
Echo ========================================
RAMMap -Ew

Echo ========================================
Echo Emptying Priority 0 Standby List
Echo ========================================
RAMMap -E0

Echo ======== RAM Cleanup Completed =========