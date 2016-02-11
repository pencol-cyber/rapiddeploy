@echo off
color 0a
echo __________________________________________________________________________
echo ################## ddd ####################################################\
echo                    ddd                                    rapidlocalpwd  ##\
echo                    ddd                                                   ##\
echo    r rrrrr       d ddd                                                   ##\
echo   rrrr  rrr    ddd ddd                              prccdc toolkit 2016  ##\
echo   rrr   rrr   ddd  ddd                                  bofh@pencol.edu  ##\
echo   rrr         dddd ddd                                                   ##\
echo   rrr          ddddddd                                                   ##\
echo   rrr
if exist userlist.txt (del userlist.txt)
if exist list.txt (del list.txt)
timeout 5
cls
echo This modules will change the authentication password for every local account to
echo a new password that you specify
echo[
echo Please enter the password:
set /P newpass01=
echo[
echo Please confirm the new password:
set /P newpass02=
if %newpass01% == %newpass02% (echo "Password [ %newpass01% ] confirmed: Proceeding") ELSE goto :quit
@echo[   
net user | find /v "The command completed" | find /v "User accounts for" | find /v "--------" | findstr [a-z][a-z] > userlist.txt
for /f "eol=; tokens=1" %%u in (userlist.txt) do echo %%u >> list.txt
for /f "eol=; tokens=2" %%v in (userlist.txt) do echo %%v >> list.txt
for /f "eol=; tokens=3" %%w in (userlist.txt) do echo %%w >> list.txt
color 07
for /f %%x in (list.txt) do echo rapidlocalpwd will now try to process the User Account: %%x
@echo[          
timeout 5
for /f %%x in (list.txt) do call :verify %%x
echo [!!!] ... All iterations completed. No more default local passwords on this system.
del userlist.txt list.txt
timeout 10
goto :eof

:verify
echo Verifying basic sanity for %1 ....
if not %1 == "" call :chpass %1 
goto :eof

:chpass
echo [ %1 ]   user information
net user %1 | findstr /C:"Account Active"
net user %1 | findstr /C:"Local Group Memberships"
net user %1 | findstr /C:"Password last set"
net user %1 | findstr /C:"Comment"
@echo[       
echo [!] Changing %1's password to [ %newpass01% ]
echo net user %1 %newpass01% /comment:"Password changed by Rapiddeploy PRCCDC Toolkit at %TIME% on %DATE%"
echo .... Updated information for %1
net user %1 | findstr /C:"Password last set"
net user %1 | findstr /C:"Comment"
echo "[!] .... Done"
@echo[     
goto :eof

:quit
echo An Error occurred
goto :eof

:eof