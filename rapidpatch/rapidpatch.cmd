@echo off
color 0a
echo __________________________________________________________________________
echo ################## ddd ####################################################\
echo                    ddd                                       rapidpatch  ##\
echo                    ddd                                                   ##\
echo    r rrrrr       d ddd                                                   ##\
echo   rrrr  rrr    ddd ddd                              prccdc toolkit 2016  ##\
echo   rrr   rrr   ddd  ddd                                  bofh@pencol.edu  ##\
echo   rrr         dddd ddd                                                   ##\
echo   rrr          ddddddd                                                   ##\
echo   rrr
timeout 8
	rem
	rem TODO: Add Server 2003/2008/2012 patch lists
	rem TODO: Add alternate URL decision tree
	rem
set NEEDS_REBOOT=0
set RD_Agent=%~dp0\wget.exe
set RD_AgentString="'RapidDeploy tool for fetching crtitical MS patches at PRCCDC 2016 bofh@pencol.edu'"
cls
color 07
echo ###########################################################################
echo This tool will fetch patches from Github by default. If you want to change  
echo this behavior invoke repiddeploy with an additional source flag
echo[
echo Examples:
echo "rapidpatch.cmd "microsoft"      -- download from windows update "
echo "rapidpatch.cmd <URL>            -- download from local mirror at <URL> "
echo[
echo[
	echo ..... Initiating Sytem Fingerprint
	systeminfo | find /I "OS Name" > tmp.os
	systeminfo | find /I "System Type" > tmp.arch
	FOR /F "eol=; tokens=4,5 delims= " %%i in (tmp.os) do set OSNAME=%%i%%j
	FOR /F "eol=; tokens=3 delims= " %%i in (tmp.arch) do set OSARCH=%%i
	del tmp.os tmp.arch rapid_win.txt rapid_lose.txt
	echo ..... Complete
cls
echo ###########################################################################
echo -----------  I will now be using logic for:
ver
echo OS:               %OSNAME%
echo Architecture:     %OSARCH%
echo[
echo -----------  And will continue with rapid deployment
echo -----------  Press CNTRL + C if you want to halt me
echo[
echo[
set Patch_Description_MS03-039="MS03-039: Remote Code Execution in RPC DCOM aka. MS Blaster"
set Patch_Description_MS05-039="MS05-039: Remote Code Execution in Plug & Play"
set Patch_Description_MS07-029="MS07-029: Remote Code Execution in Microsoft DNS Service"
set Patch_Description_MS08-067="MS08-067: Remote Code Execution in Windows Server Service aka. Red Teams Little Helper"
set Patch_Description_MS09-001="MS09-001: Remote Code Execution in SMB service"
set Patch_Description_MS09-050="MS09-050: Vulnerabilities in SMBv2 trigger Remote Code Execution"
set Patch_Description_MS10-054="MS10-054: Multiple Vulnerabilites trigger Remote Code Execution in SMB service"
set Patch_Description_MS10-061="MS10-061: Remote Code Execution in Print Spooler Service"
set Patch_Description_MS10-065="MS10-065: Multiple Vulnerabilites in Internet Information Services"
set Patch_Description_MS12-005="MS12-005: Remote Code Execution in Microsoft Office dispatcher"
set Patch_Description_MS12-020="MS12-020: Denial of Service Condition in Remote Desktop Protocol"
set Patch_Description_MS14-025="MS14-025: Security Update to address Pass The Hash authentication aka. PTH"
set Patch_Description_MS14-068="MS14-068: Flaws in Kerberos Authentication could lead to complete Domain pwnage aka. MimiKatz"
set Patch_Description_MS15-034="MS15-034: Remote code execution in HTTP.sys driver"
set Patch_Description_MS15-067="MS15-067: Remote Code Execution in Windows Remote Desktop Protocol"
set Patch_Description_MS15-127="MS15-127: Remote Code Execution in Active Directory DNS Service"
set Patch_Description_MS15-128="MS15-128: Remote Code Execution in .NET Framework"
set webroot=https://github.com/pencol-cyber/patches/raw/master

timeout 6
	rem echo %OSNAME%
	rem Fixup for 'WindowsVistaT' edge case
	rem
	if %OSNAME% == "WindowsVistaT" (set OSNAME=WindowsVista)
goto %OSNAME%

:Windows10
	echo Assembling Patch list for %OSNAME%
goto Win10_%OSARCH%

:Win10_x64-based
	echo reached sub arch          %OSARCH% 
	set branch=Win10/x64
	set patchdir=Win10_x64
goto Win10_All

:Win10_X86-based
	echo reached sub arch          %OSARCH% 
	set branch=Win10/x86
	set patchdir=Win10_x86

goto EOF

:Win10_All
	if not exist %patchdir% (mkdir %patchdir%)
	echo Fetching and then installing packages .......
	echo[
	echo Locked out by M$, sorry friend
	echo Nothing I can do for Windows 10
goto EOF

:Windows8
	echo Assembling Patch list for %OSNAME%
goto Win8_%OSARCH%

:Win8_x64-based
	echo reached sub arch          %OSARCH% 
	set branch=Win8/x64
	set patchdir=Win8_x64
goto Win8_All

:Win8_X86-based
	echo reached sub arch          %OSARCH% 
	set branch=Win8/x86
	set patchdir=Win8_x86
goto Win8_All

:Win8_All
	set MS15-034_URL=%webroot%/%branch%/MS15-034.msu
	set MS15-067_URL=%webroot%/%branch%/MS15-067.msu
	set MS15-128_URL=%webroot%/%branch%/MS15-128.msu
	if not exist %patchdir% (mkdir %patchdir%)
	echo Fetching and then installing packages .......
	echo[
	echo %Patch_Description_MS15-034%
	call :push_new MS15-034 %MS15-034_URL%
	echo %Patch_Description_MS15-067%
	call :push_new MS15-067 %MS15-067_URL%
	echo %Patch_Description_MS15-128%
	call :push_new MS15-128 %MS15-128_URL%
goto skel

:Windows7
	echo Assembling Patch list for %OSNAME%
goto Win7_%OSARCH%

:Win7_x64-based
	echo reached sub arch          %OSARCH% 
	set branch=Win7/x64
	set patchdir=Win7_x64
goto Win7_All

:Win7_X86-based
	echo reached sub arch          %OSARCH% 
	set branch=Win7/x86
	set patchdir=Win7_x86
goto Win7_All

:Win7_All
	set MS10-054_URL=%webroot%/%branch%/MS10-054.msu
	set MS10-061_URL=%webroot%/%branch%/MS10-061.msu
	set MS12-005_URL=%webroot%/%branch%/MS12-005.msu
	set MS12-020_URL=%webroot%/%branch%/MS12-020.msu
	set MS12-020b_URL=%webroot%/%branch%/MS12-020-v2.msu
	set MS15-067_URL=%webroot%/%branch%/MS15-067.msu
	set MS15-067b_URL=%webroot%/%branch%/MS15-067-v2.msu
	set MS15-128_URL=%webroot%/%branch%/MS15-128.msu
	if not exist %patchdir% (mkdir %patchdir%)
	echo Fetching and then installing packages .......
	echo[
	echo %Patch_Description_MS10-054%
	call :push_new MS10-054 %MS10-054_URL%
	echo %Patch_Description_MS10-061%
	call :push_new MS10-061 %MS10-061_URL%
	echo %Patch_Description_MS12-005%
	call :push_new MS12-005 %MS12-005_URL%
	echo %Patch_Description_MS12-020%
	call :push_new MS12-020 %MS12-020_URL%
	echo %Patch_Description_MS12-020% II
	call :push_new MS12-020-v2 %MS12-020b_URL%
	echo %Patch_Description_MS15-067%
	call :push_new MS15-067 %MS15-067_URL%
	echo %Patch_Description_MS15-067% II
	call :push_new MS15-067-v2 %MS15-067b_URL%
	echo %Patch_Description_MS15-128%
	call :push_new MS15-128 %MS15-128_URL%
goto skel

:WindowsVista
	echo Assembling Patch list for %OSNAME%
goto WinVista_%OSARCH%

:WinVista_x64-based
	echo reached sub arch          %OSARCH% 
	set branch=WinVista/x64
	set patchdir=WinVista_x64
goto WinVista_All

:WinVista_X86-based
	echo reached sub arch          %OSARCH% 
	set branch=WinVista/x86
	set patchdir=WinVista_x86
goto WinVista_All

:WinVista_All
	set MS08-067_URL=%webroot%/%branch%/MS08-067.msu
	set MS09-001_URL=%webroot%/%branch%/MS09-001.msu
	set MS09-050_URL=%webroot%/%branch%/MS09-050.msu
	set MS10-054_URL=%webroot%/%branch%/MS10-054.msu
	set MS10-061_URL=%webroot%/%branch%/MS10-061.msu
	set MS12-005_URL=%webroot%/%branch%/MS12-005.msu
	set MS12-020_URL=%webroot%/%branch%/MS12-020.msu
	set MS15-128_URL=%webroot%/%branch%/MS15-128.msu
	if not exist %patchdir% (mkdir %patchdir%)
	echo Fetching and then installing packages .......
	echo[
	echo %Patch_Description_MS08-067%
	call :push_new MS08-067 %MS08-067_URL%
	echo %Patch_Description_MS09-001%
	call :push_new MS09-001 %MS09-001_URL%
	echo %Patch_Description_MS09-050%
	call :push_new MS09-050 %MS09-050_URL%
	echo %Patch_Description_MS10-054%
	call :push_new MS10-054 %MS10-054_URL%
	echo %Patch_Description_MS10-061%
	call :push_new MS10-061 %MS10-061_URL%
	echo %Patch_Description_MS12-005%
	call :push_new MS12-005 %MS12-005_URL%
	echo %Patch_Description_MS12-020%
	call :push_new MS12-020 %MS12-020_URL%
	echo %Patch_Description_MS15-128%
	call :push_new MS15-128 %MS15-128_URL%
goto skel

:WindowsXP
	echo Assembling Patch list for %OSNAME%
goto WinXP_%OSARCH%

:WinXP_x64-based
	echo Windows XP 64 bit. No. Just no. I'm not writing anything for this. You're on your own.
goto EOF

:WinXP_X86-based
	echo reached sub arch          %OSARCH% 
	set branch=WinXP/x86
	set patchdir=WinXP_x86
goto WinXP_All

:WinXP_All
	set MS03-039_URL=%webroot%/%branch%/MS03-039.exe
	set MS05-039_URL=%webroot%/%branch%/MS05-039.exe
	set MS08-067_URL=%webroot%/%branch%/MS08-067.exe
	set MS09-001_URL=%webroot%/%branch%/MS09-001.exe
	set MS10-054_URL=%webroot%/%branch%/MS10-054.exe
	set MS10-061_URL=%webroot%/%branch%/MS10-061.exe
	set MS12-005_URL=%webroot%/%branch%/MS12-005.exe
	set MS12-020_URL=%webroot%/%branch%/MS12-020.exe
	if not exist %patchdir% (mkdir %patchdir%)
	echo Fetching and then installing packages .......
	echo[
	echo %Patch_Description_MS03-039%
	call :push_old MS03-039 %MS03-039_URL%
	echo %Patch_Description_MS05-039%
	call :push_old MS05-039 %MS05-039_URL%
	echo %Patch_Description_MS08-067%
	call :push_old MS08-067 %MS08-067_URL%
	echo %Patch_Description_MS09-001%
	call :push_old MS09-001 %MS09-001_URL%
	echo %Patch_Description_MS10-054%
	call :push_old MS10-054 %MS10-054_URL%
	echo %Patch_Description_MS10-061%
	call :push_old MS10-061 %MS10-061_URL%
	echo %Patch_Description_MS12-005%
	call :push_old MS12-005 %MS12-005_URL%
	echo %Patch_Description_MS12-020%
	call :push_old MS12-020 %MS12-020_URL%
goto skel

:skel
	color 0a
	if exist rapid_win.txt start /low /min notepad.exe rapid_win.txt
	if exist rapid_lose.txt start /low /min notepad.exe rapid_lose.txt
	echo[
	echo Please review the autopatching logs to find any mistakes that I have surely made
	echo[
	timeout 5
	if %NEEDS_REBOOT% GEQ 1 (goto :schedule_reboot)
	goto EOF

:push_old
	if exist %patchdir%\%1.exe call :cleanup %1.exe
	if not exist %patchdir%\%1.exe call :fetch_patch %1.exe %2
	if exist %patchdir%\%1.exe call :install_patch_oldstyle %1.exe
	goto EOF

:push_new
	if exist %patchdir%\%1.msu call :cleanup %1.msu
	if not exist %patchdir%\%1.msu call :fetch_patch %1.msu %2
	if exist %patchdir%\%1.msu call :install_patch_newstyle %1.msu
	goto EOF

:cleanup
	echo Patch %1 is already in the download cache
	dir %patchdir%\%1
	echo Do you want me to remove it?
	set /P CONFIRM=[y/N]  
	if /I %CONFIRM% == "y" (del %patchdir%\%1) ELSE echo keeping the file
	set CONFIRM=""
	goto EOF

:fetch_patch
	color 0c
	echo Invoking: %RD_Agent% -U %RD_AgentString% %2 --no-check-certificate -O %patchdir%\%1 -t 5 -T 20 -a debug.txt >> rapid_win.txt
	start /wait %RD_Agent% %2 --no-check-certificate -O %patchdir%\%1 -t 5 -T 20 -a debug.txt -U %RD_AgentString%
	goto EOF


:install_patch_oldstyle
	color 0f
	echo Invoking: C:\Windows\System32\msiexec.exe /passive /norestart /i %patchdir%\%1 >> rapid_win.txt
	start /wait C:\Windows\System32\msiexec.exe /passive /norestart /i %patchdir%\%1
	rem if %ERRORLEVEL%==0 set LAST_SUCCESS=1
	call :success_patch %1
	goto EOF

:install_patch_newstyle
	color 0f
	echo Invoking: C:\Windows\System32\wusa.exe /quiet /norestart %patchdir%\%1 >> rapid_win.txt
	start /wait C:\Windows\System32\wusa.exe /quiet /norestart %patchdir%\%1
	rem if %ERRORLEVEL%==0 set LAST_SUCCESS=1
	call :success_patch %1
	goto EOF

:success_patch
	color 0a
	echo Sucessfully patched %1 on %OSNAME% %OSARCH%
	echo [+]
	echo [!] Sucessfully patched %1 on %OSNAME% %OSARCH% >> rapid_win.txt
	set NEEDS_REBOOT=1
	goto EOF

:fail_patch
	color 0c
	echo Patch %1 on %OSNAME% %OSARCH% is not confirmed
	echo [-]
	echo [X] Patch %1 on %OSNAME% %OSARCH% is not confirmed >> rapid_lose.txt
	goto EOF

:schedule_reboot
	echo[
	echo[
	echo "In order to finish patching, I need to reboot the machine now"
	echo[
	echo[
	echo "If now is not a good time to reboot, cancel the reboot with --> /shutdown /a"
     	shutdown /r /t 45 /c "RapidPatch has finished with auto patching - Rebooting this machine in 45 seconds" /d p:2:18

:EOF