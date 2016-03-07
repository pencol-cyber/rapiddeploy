@echo off
color 0a
echo __________________________________________________________________________
echo ################## ddd ####################################################\
echo                    ddd                                      rapidsentry  ##\
echo                    ddd                                                   ##\
echo    r rrrrr       d ddd                                                   ##\
echo   rrrr  rrr    ddd ddd                              prccdc toolkit 2016  ##\
echo   rrr   rrr   ddd  ddd                                  bofh@pencol.edu  ##\
echo   rrr         dddd ddd                                                   ##\
echo   rrr          ddddddd                                                   ##\
echo   rrr
echo[
		rem
		rem More outhouse scripting
		rem
		rem Be warned: This does *not* cover WMI or AD based persistence, maybe in another lifetime
		rem
		rem WinXP / Server 2003 find something else, the loop interation delay will never 
		rem kick in for these, and the box will redline from the constant undelayed loop
		rem
	cd %~dp0
	set HASHING=%~dp0\md5sum.exe
	query session | findstr /I Active >> loggedin.txt
	FOR /F "eol=; tokens=2 delims= " %%u in (loggedin.txt) do echo %%u >> notify_users.txt
	del loggedin.txt
	set KEY1=hklm.software.microsoft.currentversion.run
	set KEY2=hklm.software.microsoft.currentversion.runonce
	set KEY3=hklm.software.microsoft.currentversion.runservices
	set KEY4=hklm.software.microsoft.currentversion.runservicesonce
	set KEY5=hklm.software.microsoft.windowsnt.currentversion.winlogon
	set KEY6=hklm.software.microsoft.windowsnt.currentversion.imgfile
	set KEY7=hkcu.software.microsoft.currentversion.run
	set KEY8=hkcu.software.microsoft.currentversion.runonce
	set KEY9=hkcu.software.microsoft.currentversion.runservices
	set KEY10=hkcu.software.microsoft.currentversion.runservicesonce
	set KEY11=hkcu.software.microsoft.windowsnt.currentversion.winlogon
	set KEY12=hklm.system.currentcontrolset.services
	timeout 5
goto :main

:set_orig_hashes
	cd baseline
	%HASHING% %KEY1%.reg > %KEY1%.md5
	%HASHING% %KEY2%.reg > %KEY2%.md5
	%HASHING% %KEY3%.reg > %KEY3%.md5
	%HASHING% %KEY4%.reg > %KEY4%.md5
	%HASHING% %KEY5%.reg > %KEY5%.md5
	%HASHING% %KEY6%.reg > %KEY6%.md5
	%HASHING% %KEY7%.reg > %KEY7%.md5
	%HASHING% %KEY8%.reg > %KEY8%.md5
	%HASHING% %KEY9%.reg > %KEY9%.md5
	%HASHING% %KEY10%.reg > %KEY10%.md5
	%HASHING% %KEY11%.reg > %KEY11%.md5
	%HASHING% schtasks.txt > schtasks.md5
	%HASHING% link_autorun.txt > link_autorun.md5
	%HASHING% %KEY12%.reg > %KEY12%.md5
	cd ..
	cls
	goto :EOF


:notify_user
	FOR /F %%x in (notify_users.txt) do msg %%x Someone or Something has modified %1
	goto :EOF


:export_registries
	rem args: DIR
	if exist %1 (
	cd %1
	reg export HKLM\Software\Microsoft\Windows\CurrentVersion\Run %KEY1%.reg /y
	reg export HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce %KEY2%.reg /y
	reg export HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices %KEY3%.reg /y
	if not exist hklm.software.microsoft.currentversion.runservices.reg (echo "empty" > %KEY3%.reg)
	reg export HKLM\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce %KEY4%.reg /y
	if not exist hklm.software.microsoft.currentversion.runservicesonce.reg (echo "empty" > %KEY4%.reg)
	reg export "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" %KEY5%.reg /y
	reg export "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" %KEY6%.reg /y
	reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Run %KEY7%.reg /y
	reg export HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce %KEY8%.reg /y
	reg export HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices %KEY9%.reg /y
	if not exist hkcu.software.microsoft.currentversion.runservices.reg (echo "empty" > %KEY9%.reg)
	reg export HKCU\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce %KEY10%.reg /y
	if not exist hkcu.software.microsoft.currentversion.runservicesonce.reg (echo "empty" > %KEY10%.reg)
	reg export "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" %KEY11%.reg /y
	dir /b /s C:\Windows\System32\Tasks\ > schtasks.txt
	if exist %USERPROFILE%"\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" (dir /b /s %USERPROFILE%"\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" > link_autorun.txt)
	if exist %PROGRAMDATA%"\Microsoft\Windows\Start Menu\Programs\Startup" (dir /b /s %PROGRAMDATA%"\Microsoft\Windows\Start Menu\Programs\Startup" >> link_autorun.txt)
	if not exist link_autorun.txt (echo "empty" > link_autorun.txt) 
	reg export HKLM\SYSTEM\CurrentControlSet\Services %KEY12%.reg /y
	cd ..
	cls
	)
	goto :EOF


:hash_check
	rem args: exported registry hive
	cd current
	%HASHING% %~dp0\current\%1 > %~dp0\alerts\current_checksum.txt	
	cd ..
	goto :EOF


:set_baseline
	if not exist baseline (
	mkdir baseline
	mkdir current
	mkdir alerts
	call :export_registries baseline
	)
	goto :EOF

	
:confirm_changes
	rem args: MD5 / REGKEY / Description
	cls
	echo Interactive: Acknowledge or Deny changes to %3
	echo I am just a script, I cannot decide if a change was intentional or not.
	echo[
	echo If you are certain the previously shown changes were intended, and created by you,
	echo then select 'Y' to overwrite the former baseline values for an element to reflect the
	echo updated changes.
	echo[
	echo Otherwise this script will continue to remind you of any modifications that
	echo differ from the original baseline images until you fix them manually, or revert them
	echo by selecting the 'R' option to invoke a rollback.
	echo[
	set /P UPDATE_IMAGES=[y/r/N]  
	if /I %UPDATE_IMAGES%==y (call :update_images %1 %2 %3) ELSE echo Not updating
	if /I %UPDATE_IMAGES%==r (call :registry_revert %1 %2 %3) ELSE echo .. returning to main
	goto :EOF
 

:update_images
	echo Replacing the original values for Key %3 
	copy /y alerts\current_checksum.txt baseline\%1
	copy /y current\%2 baseline\%2
	goto :EOF


:registry_revert
		rem A misquoted \"Windows NT"\ regkey could go off the rails here
		rem so this function is still nerfed
		rem
		rem echo [!!] Reverting %3 to the values found in %~dp0\baseline\%2
		rem reg delete %3 /va
		rem reg import baseline\%2
	echo[
	echo Do you want to revert the REGKEY %3 to it's original state?
	echo[
	set /P REVERT=[y/N]
	if /I %REVERT%==n (goto :EOF)
	echo This function is nerfed for now.
	echo[
	echo Delete the entire registry key "%3"
	echo Then import the one found in %~dp0\baseline
	echo[
	echo Use the following commands:
	echo[
	echo reg delete %3 /va
	echo reg import %~dp0\baseline\%2
	echo[
	goto :EOF


:loop_reg
	rem args: MD5 / REGKEY / Description
	set RESULT=FAILED
	echo [!] Checking %3 against %1
	FOR /F "eol=; tokens=1 delims= " %%h in (%~dp0\baseline\%1) do set SOURCE_HASH=%%h
	call :hash_check %2
	FOR /F "eol=; tokens=1 delims= " %%r in (%~dp0\alerts\current_checksum.txt) do set RESULT_HASH=%%r
	echo MD5 Checksum: %RESULT_HASH%
	IF %SOURCE_HASH%==%RESULT_HASH% set RESULT=OK
	echo Check Returns: %RESULT%
	IF %RESULT%==FAILED (
		call :notify_user %3
		reg query %3 >> %~dp0\alerts\alert.txt
		echo[ >> %~dp0\alerts\alert.txt
		echo MD5 Checksum Mismatch >> %~dp0\alerts\alert.txt
		echo original version: %SOURCE_HASH% >> %~dp0\alerts\alert.txt
		echo modified version: %RESULT_HASH% >> %~dp0\alerts\alert.txt
		echo[ >> %~dp0\alerts\alert.txt >> %~dp0\alerts\alert.txt
		echo Modification detected on %DATE% at %TIME% >> %~dp0\alerts\alert.txt
		echo[ >> %~dp0\alerts\alert.txt
		echo Remediation Action: Replace the regkey %3 with a prior version known to be good >> %~dp0\alerts\alert.txt
		notepad.exe %~dp0\alerts\alert.txt
		call :confirm_changes %1 %2 %3
		cd alerts
		ren alert.txt alert_old_%RANDOM%.txt
		cd ..
		)
	echo[
	goto :EOF


:loop_tasks
	rem args: MD5 / REGKEY / Description
	set RESULT=FAILED
	echo [!] Checking %3 against %1
	FOR /F "eol=; tokens=1 delims= " %%h in (%~dp0\baseline\%1) do set SOURCE_HASH=%%h
	call :hash_check %2
	FOR /F "eol=; tokens=1 delims= " %%r in (%~dp0\alerts\current_checksum.txt) do set RESULT_HASH=%%r
	echo MD5 Checksum: %RESULT_HASH%
	IF %SOURCE_HASH%==%RESULT_HASH% set RESULT=OK
	echo Check Returns: %RESULT%
	IF %RESULT%==FAILED (
		call :notify_user %3
		C:\Windows\System32\taskschd.msc
		)
	echo[
	goto :EOF

:loop_linkstarts
	rem args: MD5 / REGKEY / Description
	set RESULT=FAILED
	echo [!] Checking %3 against %1
	FOR /F "eol=; tokens=1 delims= " %%h in (%~dp0\baseline\%1) do set SOURCE_HASH=%%h
	call :hash_check %2
	FOR /F "eol=; tokens=1 delims= " %%r in (%~dp0\alerts\current_checksum.txt) do set RESULT_HASH=%%r
	echo MD5 Checksum: %RESULT_HASH%
	IF %SOURCE_HASH%==%RESULT_HASH% set RESULT=OK
	echo Check Returns: %RESULT%
	IF %RESULT%==FAILED (
		call :notify_user %3
		explorer.exe %USERPROFILE%"\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
		explorer.exe %PROGRAMDATA%"\Microsoft\Windows\Start Menu\Programs\Startup"
		)
	echo[
	goto :EOF


:loop_services
	rem args: MD5 / REGKEY / Description
	set RESULT=FAILED
	echo [!] Checking %3 against %1
	FOR /F "eol=; tokens=1 delims= " %%h in (%~dp0\baseline\%1) do set SOURCE_HASH=%%h
	call :hash_check %2
	FOR /F "eol=; tokens=1 delims= " %%r in (%~dp0\alerts\current_checksum.txt) do set RESULT_HASH=%%r
	echo MD5 Checksum: %RESULT_HASH%
	IF %SOURCE_HASH%==%RESULT_HASH% set RESULT=OK
	echo Check Returns: %RESULT%
	IF %RESULT%==FAILED (
		call :notify_user %3
		C:\Windows\System32\services.msc
		)
	echo[
	goto :EOF


:main

color 07
echo Creating registry baselines ..
call :set_baseline
echo [!] ... registry baselines complete
echo[
echo[
echo Generating 128 bit hash values of registry baselines ..
call :set_orig_hashes
echo [!] ... 128 bit hash values of registry baselines complete
echo[
echo[
rem Main Loop
rem 
FOR /l %%l in (1, 1, 65535) do (
	call :export_registries current
	timeout 3
	
	echo Looking for well known persistant agent methods: Pass %%l 
	call :loop_reg %KEY1%.md5 %KEY1%.reg HKLM\Software\Microsoft\Windows\CurrentVersion\Run
	call :loop_reg %KEY2%.md5 %KEY2%.reg HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
	call :loop_reg %KEY3%.md5 %KEY3%.reg HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices
	call :loop_reg %KEY4%.md5 %KEY4%.reg HKLM\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
	call :loop_reg %KEY5%.md5 %KEY5%.reg "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
	call :loop_reg %KEY6%.md5 %KEY6%.reg "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
	call :loop_reg %KEY7%.md5 %KEY7%.reg HKCU\Software\Microsoft\Windows\CurrentVersion\Run
	call :loop_reg %KEY8%.md5 %KEY8%.reg HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce
	call :loop_reg %KEY9%.md5 %KEY9%.reg HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices
	call :loop_reg %KEY10%.md5 %KEY10%.reg HKCU\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce
	call :loop_reg %KEY11%.md5 %KEY11%.reg "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
	call :loop_services %KEY12%.md5 %KEY12%.reg "Windows System Services"
	call :loop_tasks schtasks.md5 schtasks.txt "Scheduled Tasks"
	call :loop_linkstarts link_autorun.md5 link_autorun.txt "Filesystem Autostart Links"
	timeout 300
	)	

:EOF