@echo off

set cid=
set fpath=
set installer=

:GETOPTS
 if /i "%~1" == "/cid" set "cid=%2" & shift
 if /i "%~1" == "/p" set "fpath=%2" & shift
 if /i "%~1" == "/i" set "installer=%2" & shift
 shift
if not [%1]==[] goto GETOPTS

if [%cid%]==[] (
echo ERROR: falcon cid is undefined
EXIT /B 1
)

if [%fpath%]==[] (
echo ERROR: network path is undefined
EXIT /B 1
)

if [%installer%]==[] (
echo ERROR: sensor installer is undefined
EXIT /B 1
)

set csfolder="C:\Windows\System32\drivers\CrowdStrike"

if NOT EXIST %csfolder% (
pushd %fpath%
%installer% /install /quiet /norestart CID=%cid%
popd
)