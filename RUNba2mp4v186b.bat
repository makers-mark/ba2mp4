@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
	SET /A cols=57
	SET /A lines=73
	MODE CON:COLS=%cols% LINES=%lines%
	COLOR 0B	
	SET "autoopen=remark_this_value_to_stop_automatically_opening_videos"
	::SET "autoopenfolder=remark_this_value_to_stop_automatically_opening_folders"
	::SET "autoopengif=remark_this_value_to_stop_automatically_opening_gifs"
	SET "vers=1.86b"
	SET "dirsort=/o-d"
	SET "sort=/on"
::set sort equal to /od if images have no number padding like image1.jpg instead of image0001.jpg
	TITLE Boot Animation to Mp4 v%vers%
	SET "logall=>>"%~dp0log.txt" 2>>&1"
	SET "logerr=1>NUL 2>>errorlog.txt"
	SET "gifpixelformat=-pix_fmt rgb8"
	SET "fformat=yuv420p"
	SET /A defaultfolderrepeats=1
	SET /A "defaultbitrate=6100"
	SET /A "bitrate=%defaultbitrate%"
	SET "renumprepend=_"
	SET /A "defaultjpegquality=7"
	SET /A "jpegquality=%defaultjpegquality%"
	SET "motovidname=qooqle"
	SET "bootanimationfilename=bootanimation.zip"
	SET "zipfolder=Zips"
	SET "madezipfolder=Made_Zips"
	SET "gifsfolder=Gifs"
	SET "outputtogif="
	SET "androidfolder=/data/local/"
	SET "savefolder=Videos"
	SET "savename=bootanimation"
	SET "quality=-crf 23"
	SET "videotype=mp4"
	SET "ffdebug="
	SET "ffshowb=-hide_banner"
	SET /A aspectmultiplier=10000
	SET "stno=-start_number 1"
	SET "stnorng=-start_number_range 19"
	SET "log=%logall%"
	IF "%~1"=="-d" (
		SET "debugmode=1"
		SET "ffdebug=-loglevel debug"
		SET "ffshowb=%"
		MODE CON:COLS=140 LINES=4000
		COLOR 07
	)
	IF EXIST "%~dp0errorlog.txt" DEL /Q "%~dp0errorlog.txt"
	IF EXIST "%~dp0log.txt" DEL /Q "%~dp0log.txt"
	IF EXIST "%~dp0fztemp" RMDIR /Q "%~dp0fztemp"
	IF NOT EXIST "%~dp0%madezipfolder%" MKDIR "%~dp0%madezipfolder%"
	IF NOT EXIST "%~dp0%zipfolder%" MKDIR "%~dp0%zipfolder%"
	IF NOT EXIST "%~dp0%savefolder%" MKDIR "%~dp0%savefolder%"
	IF EXIST "%~dp0copylist" DEL "%~dp0copylist" /q

:MAINMENUBA2MP4
	CALL :DRAWHEADBA2MP4
	ECHO.
	ECHO.Use options 2 or 3 to convert from Mp4 style boot
	ECHO.animation to jpg style, or vice versa. Or make a video.
	ECHO.
	ECHO.Use Quickport, options 4 or 5, to change resolution and
	ECHO.output a "same type" bootanimation.
	ECHO.
	ECHO._________________________________________________________
	ECHO.
	ECHO.
	ECHO.  1 - Use ADB To Pull Your Boot Animation.
	ECHO.
	ECHO.  2 - Convert Zips In "%zipfolder%"
	ECHO.
	ECHO.  3 - Convert Zips In "%madezipfolder%"
	ECHO.
	ECHO.  4 - Quickport Zips In "%zipfolder%"
	ECHO.
	ECHO.  5 - Quickport Zips In "%madezipfolder%"
	ECHO.
	ECHO.  6 - Combine Videos In "%savefolder%" into one.
	ECHO.
	ECHO.  7 - Exit
	ECHO.
	ECHO.
	IF EXIST "%~dp0temp" RMDIR "%~dp0temp" /s /q %log%
	CALL :RESETVALUES
	CHOICE /n /m "Please Select A Menu Number:" /c:1234567
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF ERRORLEVEL 5 SET K=5
		IF ERRORLEVEL 6 SET K=6
		IF ERRORLEVEL 7 SET K=7
		IF %K%==1 GOTO :ADBTOGETIT
		IF %K%==2 CALL :BAZIPSFOLDER %zipfolder%
		IF %K%==3 CALL :BAZIPSFOLDER %madezipfolder%
		IF %K%==4 SET qport=1&CALL :BAZIPSFOLDER %zipfolder%
		IF %K%==5 SET qport=1&CALL :BAZIPSFOLDER %madezipfolder%
		IF %K%==6 GOTO :CONCATALL
		IF %K%==7 GOTO :FINISH
	GOTO :MAINMENUBA2MP4

:ADBTOGETIT
	CALL :GETBA
	SET "filename=%savename%.zip"
	CALL :UNZIP "%filename%"
	CALL :DUPENAME "%zipfolder%" "savename" "zip"
	MOVE "%~dp0%filename%" "%~dp0%zipfolder%\%savename%.zip" %log%
	SET "filename=%savename%.zip"
	CALL :READDESC
	IF %filetype% EQU 1	GOTO :YOURSETTINGS
	IF %filetype% EQU 2 GOTO :JPGSETTINGS
GOTO :MAINMENUBA2MP4

:BAZIPSFOLDER
	>NUL 2>&1 (DIR /A-D-S-H/B "%~dp0%~1\*.zip"|FINDSTR "^")||GOTO :MAINMENUBA2MP4
	SET "originatingfolder=%~1"
	SET /a index=0
	CALL :DRAWHEADBA2MP4
	FOR /F "delims=" %%E IN ('dir /a-d-h/b%dirsort% "%~dp0%~1\*.zip"') DO (
		SET /A index+=1
		SET "zipfile[!index!]=%%E"
		(("%~dp0\bin\7ZA" l "%~dp0%~1\%%E"|findstr /c:" desc.txt")&&(SET "ziptype[!index!]=REG")||("%~dp0\bin\7ZA" l "%~dp0%~1\%%E"|findstr /c:"videodesc.txt")&&(SET "ziptype[!index!]=MP4")||(SET "ziptype[!index!]=FLA")) %log%
	)
	ECHO.
	ECHO.REG is a bootanimation with either pngs or jpgs
	ECHO.MP4 is a bootanimation with Mp4 video files
	ECHO.FLA is a flashable zip file with another zip inside it
	ECHO.
	ECHO.Zips in \%~1\
	ECHO.
	ECHO.No. Type Filename
	ECHO._________________________________________________________
	FOR /l %%I in (1,1,%index%) DO (IF %%I LSS 10 (ECHO. %%I. !ziptype[%%I]! !zipfile[%%I]!) ELSE (ECHO.%%I. !ziptype[%%I]! !zipfile[%%I]!))
	ECHO.
	ECHO.[Press enter to go back to the main menu]
	ECHO._________________________________________________________
	ECHO.
	ECHO.Choose a number AND press enter...
	ECHO.
  :LOOPBACK
	SET /p pickazip=: ||GOTO :MAINMENUBA2MP4
	IF %pickazip% LSS 1 GOTO :LOOPBACK
	IF %pickazip% GTR %index% GOTO :LOOPBACK
	ECHO.
	ECHO.Unzipping and reading files...
	SET filename=!zipfile[%pickazip%]!
	CALL :UNZIP "%~1\%filename%"
	SET "savename=%filename:.zip=%"
	CALL :READDESC "%~2"
	IF DEFINED qport GOTO :QUICKPORT
	IF %filetype% EQU 1	GOTO :YOURSETTINGS
	IF %filetype% EQU 2 GOTO :JPGSETTINGS
GOTO :BAZIPSFOLDER

:QUICKPORT
	IF %filetype% EQU 1 GOTO :QPREG
	IF %filetype% EQU 2 GOTO :QPMP4
:QPREG
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.  1 - Change Resolution
	ECHO.
	ECHO.  2 - Port It!
	ECHO.
	ECHO.  3 - Go To The Main Menu
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /c:123
	IF ERRORLEVEL 1 SET K=1
	IF ERRORLEVEL 2 SET K=2
	IF ERRORLEVEL 3 SET K=3
	IF %K%==1 CALL :CHANGERES&GOTO :QPREG
	IF %K%==2 GOTO :PORT2REG
	IF %K%==3 GOTO :MAINMENUBA2MP4
GOTO :QUICKPORT

:QPMP4
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.  1 - Change Resolution
	ECHO.
	ECHO.  2 - Change Bitrate ^(%bitrate%^)
	ECHO.
	ECHO.  3 - Port It!
	ECHO.
	ECHO   4 - Go To The Main Menu
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /c:1234
	IF ERRORLEVEL 1 SET K=1
	IF ERRORLEVEL 2 SET K=2
	IF ERRORLEVEL 3 SET K=3
	IF ERRORLEVEL 4 SET K=4
	IF %K%==1 CALL :CHANGEVRES&GOTO :QPMP4
	IF %K%==2 CALL :GETBITRATE
	IF %K%==3 GOTO :PORT2MP4
	IF %K%==4 GOTO :MAINMENUBA2MP4
GOTO :QUICKPORT

:PORT2MP4
	IF NOT DEFINED scale SET "scale=scale=%width%:%height%"
	IF DEFINED crop SET "videofilters=-vf "%scale%,%crop%,format=%fformat%""
	IF NOT DEFINED crop SET "videofilters=-vf "%scale%,format=%fformat%""	
	CALL :DRAWSETTINGS
	IF DEFINED bitrate SET "savename=b%bitrate%_%savename%"&SET "bitratestring=-b:v %bitrate%k"
	SET "savename=%width%x%height%_%savename%"
	CALL :DUPENAME "%madezipfolder%" "savename" "zip"
	%log% CALL :CLEARBUFF
	ECHO.
	SET /A checkheight=%height%%%2
	SET /A checkwidth=%width%%%2
	ECHO.
	ECHO.
	IF %checkheight% EQU 1 (SET /A height-=1 & ECHO.Height has been adjusted 1 pixel)
	IF %checkwidth% EQU 1 (SET /A width-=1	& ECHO.Width has been adjusted 1 pixel)
	ECHO.Working..
	FOR /L %%A IN (1,1,%staticfoldercount$%) DO (
		%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% -i "%~dp0temp\!mp4file[%%A]!" %bitratestring% -bufsize %bitrate%k %videofilters% -y "%~dp0temp\buffer\!mp4file[%%A]!"||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :QPMP4)
		ECHO.!mp4file[%%A]! complete
		ECHO.!folderrepeats[%%A]! !pauselastframe[%%A]!>>"%~dp0temp\buffer\videodesc.txt"
	)
	IF %checkheight% EQU 1 SET /A height+=1
	IF %checkwidth% EQU 1 SET /A width+=1
	SET checkheight=
	SET checkwidth=
	%log% "%~dp0\bin\7ZA" a -y -r -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0temp\buffer\*.*" -mx0
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	ECHO.Zip saved in "%madezipfolder%"
	ECHO.as "%savename%.zip"
	ECHO.
	ECHO.
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	IF DEFINED autoopenfolder START "" "%~dp0%madezipfolder%\"
	ECHO.
	ECHO.Would you like to:
	ECHO.
	ECHO.  1 - Go Back
	ECHO.
	ECHO.  2 - Go To The Main Menu
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:12
	IF ERRORLEVEL 1 SET K=1
	IF ERRORLEVEL 2 SET K=2
	IF %K%==1 (
		SET "savename=%filename:.zip=%"
		GOTO :QUICKPORT
	)
	IF %K%==2 (	
		RMDIR /Q "%~dp0temp"
		GOTO :MAINMENUBA2MP4
	)
GOTO :EOF

:PORT2REG
	CALL :DRAWSETTINGS
	IF NOT DEFINED scale SET "scale=scale=%width%:%height%"
	IF DEFINED crop (SET "videofilters=-vf "%scale%,%crop%"") ELSE (SET "videofilters=-vf "%scale%"")
	%log% CALL :CLEARBUFF
	SET "savename=%width%x%height%_%savename%"
	CALL :DUPENAME "%madezipfolder%" "savename" "zip"
	ECHO.
	ECHO.
	ECHO.Working..
	ECHO.%width% %height% %fpsout%>"%~dp0temp\buffer\desc.txt"
	FOR /L %%A IN (1,1,%staticfoldercount$%) DO (
		IF NOT EXIST "%~dp0temp\buffer\!folder[%%A]!" MKDIR "%~dp0temp\buffer\!folder[%%A]!"
		CALL :RENUM "!folder[%%A]!" !extinfolder[%%A]! %log%
		%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% %stno% %stnorng% -f image2 -i "%~dp0temp\!folder[%%A]!\%renumprepend%%%05d.!extinfolder[%%A]!" -qscale 0 %videofilters% -y "%~dp0temp\buffer\!folder[%%A]!\%renumprepend%%%05d.!extinfolder[%%A]!"||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :QPREG)
		"%~dp0\bin\7ZA" a -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0temp\buffer\!folder[%%A]!" -mx0 %log%
		ECHO.!folder[%%A]! complete
		ECHO.!foldertype[%%A]! !folderrepeats[%%A]! !pauselastframe[%%A]! !folder[%%A]!>>"%~dp0temp\buffer\desc.txt"
	)
	"%~dp0\bin\7ZA" a -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0temp\buffer\desc.txt" -mx0 %log%
	"%~dp0\bin\7ZA" d "%~dp0%madezipfolder%\%savename%.zip" thumbs.db -r %log%
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	ECHO.Zip saved in "%madezipfolder%"
	ECHO.as "%savename%.zip"
	ECHO.
	ECHO.
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	IF DEFINED autoopenfolder START "" "%~dp0%madezipfolder%\"
	ECHO.
	ECHO.Would you like to:
	ECHO.
	ECHO.  1 - Go Back
	ECHO.
	ECHO.  2 - Open Zip In The Mp4/Gif Converter
	ECHO.
	ECHO.  3 - Go to the Main Menu
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:123
	IF ERRORLEVEL 1 SET K=1
	IF ERRORLEVEL 2 SET K=2
	IF ERRORLEVEL 3 SET K=3
	IF %K%==1 (
		SET "savename=%filename:.zip=%"
		GOTO :QUICKPORT
	)
	IF %K%==2 (  
		RMDIR /q "%~dp0temp" %log%
		CALL :UNZIP "%madezipfolder%\!savename!.zip"
		SET "filename=!savename!"
		CALL :RESETVALUES
		SET savename=!filename:.zip=!
		SET qport=
		SET /a filetype=1
		CALL :READDESC
		GOTO :YOURSETTINGS
	)
	IF %K%==3 (	
		RMDIR /Q "%~dp0temp"
		GOTO :MAINMENUBA2MP4
	)	
GOTO :EOF

:CLEARBUFF
	DEL /q "%~dp0temp\buffer\*.*"
	RMDIR /q "%~dp0temp\buffer"
	MKDIR "%~dp0temp\buffer"
GOTO :EOF

:RESETVALUES
	SET bufsize=
	SET testfile=
	SET qport=
	SET append=
	SET "savename=bootanimation"
	SET videofilters=
	SET outputtogif=
	SET gif=
	SET strang=
	SET width=
	SET height=
	SET fps=
	SET fpsout=
	SET filetype=
	SET crop=
	SET scale=
	SET /A jpegquality=%defaultjpegquality%
	SET /A "bitrate=%defaultbitrate%"
	SET vidfps=
	SET vidwidth=
	SET vidheight=
GOTO :EOF

:FILLTHEVOID
	CALL :DRAWSETTINGS
	ECHO You need to input how many folder repeats you want for
	ECHO.
	ECHO the following folder(s):
	ECHO.
	ECHO.To get at least X seconds of video for a folder with '0'
	ECHO.
	ECHO.enter tx
	ECHO.
	ECHO.Example:  
	ECHO.
	ECHO.You want the last folder to play at least 10 seconds.  
	ECHO.
	ECHO.Enter 't10' or 'T 10'
	ECHO.
	ECHO._________________________________________________________
	FOR /L %%P IN (1,1,%staticfoldercount$%) DO (
		IF DEFINED gorighttovideo SET /A folderrepeats[%%P]=%defaultfolderrepeats%
		IF !folderrepeats[%%P]! EQU 0 (
			ECHO.
			ECHO.FOLDER %%P: !folder[%%P]! needs a value to loop for the video.
			ECHO.
			SET /A secondsperloop[%%P]=!frames[%%P]!/%fps% >NUL 2>&1
			SET /A secondsperlooprem[%%P]=!frames[%%P]!%%%fps% >NUL 2>&1
			ECHO.One loop of this folder will last !secondsperloop[%%P]! !secondsperlooprem[%%P]!/%fps% seconds.
			ECHO.
			CALL :SETFOLDERSUB %%P
		)
	)
GOTO :EOF

:SETFOLDERSUB
	:LOOP2
		SET /P folderrepeats[%1]=How many loops: || SET /a folderrepeats[%1]=1
		SET "tcheck=!folderrepeats[%1]:~0,1!
		IF /i "%tcheck%"=="t" (
			SET "secondswanted=!folderrepeats[%1]:~1,8!"
			SET "secondswanted=!secondswanted: =!"
			SET /A "folderrepeats[%1]=!secondswanted!/!secondsperloop[%1]!"
			SET "tcheck="
			IF "!folderrepeats[%1]!"=="0" SET "folderrepeats[%1]=1"
			GOTO :EOF
		)
		2>NUL SET /A folderrepeats[%1]=!folderrepeats[%1]!/1
		IF !folderrepeats[%1]! LSS 1 GOTO :LOOP2
GOTO :EOF

:ORIGINALRES
	IF [%~2]==[V] SET givefps=1
	FOR /F "tokens=1-8* delims=," %%A IN ('bin\FFMPEG -i "%~dp0temp\%~1" 2^>^&1^|FINDSTR /rxic:".*stream #0:0.*[0-9][0-9]x[0-9][0-9].*"') DO (
		ECHO.%%A >"%~dp0temp\imageres"
		ECHO.%%B >>"%~dp0temp\imageres"
		ECHO.%%C >>"%~dp0temp\imageres"
		ECHO.%%D >>"%~dp0temp\imageres"
		ECHO.%%E >>"%~dp0temp\imageres"
		ECHO.%%F >>"%~dp0temp\imageres"
		ECHO.%%G >>"%~dp0temp\imageres"
		ECHO.%%H >>"%~dp0temp\imageres"
	)
	IF DEFINED givefps FOR /F "tokens=1 delims= " %%d IN ('TYPE "%~dp0temp\imageres"^|FINDSTR /rxic:".*fps.*"') DO SET vidfps=%%d
	IF DEFINED givefps FOR /F "tokens=1 delims= " %%d IN ('TYPE "%~dp0temp\imageres"^|FINDSTR /rxic:".*kb/s.*"') DO (SET "vidbitrate=%%d"&SET /A "vidbitrate=!vidbitrate: =!")
	FOR /F "tokens=1-3 delims=x " %%d IN ('TYPE "%~dp0temp\imageres"^|FINDSTR /rxic:".*[0-9][0-9]x[0-9][0-9].*"') DO (SET "vidwidth=%%d"&SET /a "vidwidth=!vidwidth: =!"&SET "vidheight=%%e"&SET /a "vidheight=!vidheight: =!")
	%log% TYPE "%~dp0temp\imageres"
	DEL /Q "%~dp0temp\imageres"
	SET givefps=
GOTO :EOF

:DRAWSETTINGS
	CALL :DRAWHEADBA2MP4
	ECHO.File:"%filename%"
	ECHO.______________________________________________________-_-
	IF %filetype% EQU 1 (
		FOR /l %%z IN (1,1,%staticfoldercount$%) DO (
			SET /A totalwithrepeats[%%z]=!frames[%%z]!*!folderrepeats[%%z]! >NUL 2>&1
			SET /A stime[%%z]=!totalwithrepeats[%%z]!/%fps% >NUL 2>&1
			SET /A dtime[%%z]=!totalwithrepeats[%%z]!%%%fps% >NUL 2>&1
			IF %%z LSS 10 (
				ECHO. %%z: !foldertype[%%z]!	!folderrepeats[%%z]!	!pauselastframe[%%z]!	!folder[%%z]!
			) ELSE (
				ECHO.%%z: !foldertype[%%z]!	!folderrepeats[%%z]!	!pauselastframe[%%z]!	!folder[%%z]!
			) 
		)
	)
	IF %filetype% EQU 2 (
		IF NOT DEFINED qport FOR /L %%b IN (1,1,%staticfoldercount$%) DO ECHO.%%b: !foldertype[%%b]!	!folderrepeats[%%b]!	!pauselastframe[%%b]!	!folder[%%b]!
		ECHO._________________________________________________________
		ECHO.
		IF NOT DEFINED qport (FOR /l %%z IN (1,1,%staticfoldercount$%) DO ECHO.!folder[%%z]! will refer to !mp4file[%%z]!) ELSE (FOR /l %%z IN (1,1,%staticfoldercount$%) DO ECHO.!mp4file[%%z]!)
		ECHO._________________________________________________________
		ECHO.Source: %vidwidth%x%vidheight% @ %vidfps%fps @ %vidbitrate%kb/s
		ECHO._________________________________________________________
		IF NOT DEFINED qport (ECHO.Output: %width%x%height% @ %fps%fps @ jpg quality:%jpegquality%) ELSE (ECHO.Output: %width%x%height% @ %fps%fps @ %bitrate%kb/s)
		ECHO._________________________________________________________
		GOTO :EOF
	)
	ECHO._________________________________________________________	
	FOR /l %%M IN (1,1,%staticfoldercount$%) DO ECHO.!folder[%%M]!	Frames: !frames[%%M]! x !folderrepeats[%%M]!	Length: !stime[%%M]! !dtime[%%M]!/%fps% seconds
	ECHO._________________________________________________________
	SET /A grandtotal=0
	FOR /L %%R IN (1,1,%staticfoldercount$%) DO SET /A grandtotal=!grandtotal!+!totalwithrepeats[%%R]!
	ECHO.Total frames:	%grandtotal%
	SET /A totaltime=%grandtotal% / %fps%
	SET /A fractiontime=%grandtotal%%%%fps
	ECHO.Total time:	%totaltime% %fractiontime%/%fps% seconds
	ECHO._________________________________________________________
	ECHO.Source Resolution: %vidwidth%x%vidheight% @ %fps%fps
	ECHO._________________________________________________________
	ECHO.Output Resolution: %width%x%height% @ %fpsout%fps
	ECHO._________________________________________________________
	IF NOT DEFINED qport (
		ECHO.FFmpeg quality is set at %quality% on a scale of 0 to 51
		ECHO._________________________________________________________
	)
GOTO :EOF

:JPGSETTINGS
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.Please choose one of the following...
	ECHO.
	ECHO.
	ECHO.  1 - Export To A Jpg Bootanimation.zip
	ECHO.
	ECHO.  2 - Export To A Jpg Bootanimation And Make Mp4
	ECHO.
	ECHO.  3 - Change The Jpg Quality Level ^(%jpegquality%^)
	ECHO.
	ECHO.  4 - Change The Resolution ^(%width%x%height%^)
	ECHO.
	ECHO.  5 - Go To The Main Menu
	ECHO.
	ECHO.  6 - Exit
	ECHO.
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:123456
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF ERRORLEVEL 5 SET K=5
		IF ERRORLEVEL 6 SET K=6
		IF %K%==1 CALL :AREYOUSURE&&GOTO :MAKEJPGBA||GOTO :JPGSETTINGS
		IF %K%==2 CALL :AREYOUSURE&&(SET "gorighttovideo=1"&SET "returnfilename=%filename%"&GOTO :MAKEJPGBA)||GOTO :JPGSETTINGS
		IF %K%==3 CALL :CHANGEJPG
		IF %K%==4 CALL :CHANGEVRES
		IF %K%==5 GOTO :MAINMENUBA2MP4
		IF %K%==6 GOTO :FINISH
GOTO :JPGSETTINGS

:CHANGEJPG
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.The lower the number the better the quality, and the
	ECHO.
	ECHO.bigger the filesize.  The best is 1 while the worst
	ECHO.
	ECHO.quality is 31.
	ECHO.
	ECHO.[press enter to use the default: %defaultjpegquality%]
	ECHO._________________________________________________________
	ECHO.
	:LOOP4
	SET /P jpegquality=Enter the jpeg quality: || SET /A jpegquality=%defaultjpegquality%
	2>NUL SET /A jpegquality=%jpegquality%/1 || GOTO :LOOP4
	IF %jpegquality% LSS 1 GOTO :LOOP4
	IF %jpegquality% GTR 31 GOTO :LOOP4	
GOTO :EOF

:CHANGERES
	SET crop=
	SET scale=
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.Enter your width and height desired. Current:%width%x%height%
	ECHO.
	ECHO.[press enter to use source image size:%vidwidth%x%vidheight%]
	ECHO._________________________________________________________
	ECHO.
	:LOOP12
	SET /P width=Enter the width: || SET /A width=%vidwidth% || GOTO :LOOP12
	2>NUL SET /A width=%width%/1 || GOTO :LOOP12
	IF %width% LSS 2 GOTO :LOOP12	
	ECHO.
	:LOOP13
	SET /P height=Enter the height: || SET /A height=%vidheight% || GOTO :LOOP13
	2>NUL SET /A height=%height%/1 || GOTO :LOOP13
	IF %height% LSS 2 GOTO :LOOP13
	ECHO.
	SET "scale=scale=%width%:%height%"
	SET /A "newaspect=%aspectmultiplier%*%height%/%width%"
	SET /A "originalaspect=%aspectmultiplier%*%vidheight%/%vidwidth%"
	IF "!newaspect!" NEQ "!originalaspect!" CALL :ASPECTCHANGE
	SET newaspect=
	SET originalaspect=
GOTO :EOF

:CHANGEVRES
	SET crop=
	SET scale=
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.
	ECHO.
	ECHO.	
	ECHO._________________________________________________________
	ECHO.
	IF NOT DEFINED qport (
		ECHO.Enter your width and height desired.  These values will 
		ECHO.
		ECHO.be written to the desc.txt file in the zip that is 
		ECHO.
		ECHO.produced.
		ECHO.
	) ELSE (
		ECHO.Enter your width and height desired.
		ECHO.
	)
	ECHO.[press enter twice to use %vidwidth%x%vidheight%]
	ECHO._________________________________________________________
	ECHO.
	:LOOP1
	SET /P width=Enter the width: || 2>NUL SET /A width=%vidwidth% || GOTO :LOOP1
	2>NUL SET /A width=%width%/1 || GOTO :LOOP1
	IF %width% LSS 2 GOTO :LOOP1
	ECHO.
	:LOOP11
	SET /P height=Enter the height: || 2>NUL SET /A height=%vidheight% || GOTO :LOOP11
	2>NUL SET /A height=%height%/1 || GOTO :LOOP11
	IF %height% LSS 2 GOTO :LOOP11
	ECHO.
	SET "scale=scale=%width%:%height%"
	SET /A "newaspect=%aspectmultiplier%*%height%/%width%"
	SET /A "originalaspect=%aspectmultiplier%*%vidheight%/%vidwidth%"
	IF "!newaspect!" NEQ "!originalaspect!" CALL :ASPECTCHANGE
	SET newaspect=
	SET originalaspect=
GOTO :EOF

:ASPECTCHANGE
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.The aspect ratio is different from the original aspect
	ECHO.
	ECHO.ratio.  The first option will maintain aspect and also 
	ECHO.
	ECHO.crop.  This is equivelant to porting to another
	ECHO.
	ECHO.resolution. Would you like to:
	ECHO.
	ECHO._________________________________________________________
	ECHO.
	ECHO.  1 - Resize But Keep The Original Aspect
	ECHO.
	ECHO.  2 - Stretch Or Shrink The Images To %width%x%height%
	ECHO.
		CHOICE /n /m "Please Select A Menu Number:" /C:12
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF %K%==1 (
			IF %originalaspect% GTR %newaspect% SET "scale=scale=%width%:-1"&SET "crop=crop=%width%:%height%"
			IF %originalaspect% LSS %newaspect% SET "scale=scale=-1:%height%"&SET "crop=crop=%width%:%height%"
		)
		IF %K%==2 SET "scale=scale=%width%:%height%"&SET "crop="

GOTO :EOF

:CHANGEFPS
	CALL :DRAWSETTINGS	
	ECHO.
	ECHO.Your inbound fps is what you will see the animation being
	ECHO.
	ECHO.rendered at.  Your outbound fps is how many fps the video 
	ECHO.
	ECHO.will be encoded at AND if you export as a mp4 style 
	ECHO.
	ECHO.animation, it will declare the framerate for the mp4s.
	ECHO.
	ECHO._________________________________________________________	
	ECHO.
	:LOOP6
	SET /P fps=Enter your inbound fps? || SET /A "fps=%fps%"
	2>NUL SET /A fps=%fps%/1 || GOTO :LOOP6
	IF %fps% LSS 1 GOTO :LOOP6
	ECHO.
	:LOOP10
	SET /P fpsout=Enter your outbound fps? || SET /A "fpsout=%fpsout%"
	2>NUL SET /A fpsout=%fpsout%/1 || GOTO :LOOP10
	IF %fpsout% LSS 1 GOTO :LOOP10
	ECHO.
GOTO :EOF

:MAKEJPGBA
	CALL :DRAWSETTINGS
	IF NOT DEFINED scale SET "scale=scale=%width%:%height%"
	IF NOT DEFINED crop (SET "videofilters=-vf "scale=%width%:%height%"") ELSE (SET "videofilters=-vf "%scale%,%crop%"")
	CALL :NAMEVIDZ
	CALL :DUPENAME "%madezipfolder%" "savename" "zip"
	ECHO.%width% %height% %fps%>"%~dp0temp\desc.txt"
	ECHO.Working..
	FOR /L %%y IN (1,1,%staticfoldercount$%) DO (
		IF NOT EXIST "%~dp0temp\!folder[%%y]!" MKDIR "%~dp0temp\!folder[%%y]!"
		%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% -i "%~dp0temp\!mp4file[%%y]!" -q:v %jpegquality% -f image2 %videofilters% -y "%~dp0temp\!folder[%%y]!\%%05d.jpg"||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :JPGSETTINGS)
		"%~dp0\bin\7ZA" a -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0temp\!folder[%%y]!" -mx0 %log%
		ECHO.!foldertype[%%y]! !folderrepeats[%%y]! !pauselastframe[%%y]! !folder[%%y]!>>"%~dp0temp\desc.txt"
	)
	"%~dp0\bin\7ZA" a -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0temp\desc.txt" -mx0 %log%
	"%~dp0\bin\7ZA" d "%~dp0%madezipfolder%\%savename%.zip" thumbs.db -r %log%

	IF DEFINED gorighttovideo (
		RMDIR /q "%~dp0temp" %log%
		CALL :UNZIP "%madezipfolder%\!savename!.zip"
		SET "filename=!savename!"
		CALL :RESETVALUES
		SET savename=!filename:.zip=!
		SET /A filetype=1
		CALL :READDESC
		GOTO :LETSDOIT
	)
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	ECHO.Zip saved in "%madezipfolder%"
	ECHO.as "%savename%.zip"
	ECHO.
	ECHO.
	IF DEFINED autoopenfolder START "" "%~dp0%madezipfolder%\"
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	ECHO.
	ECHO.Would you like to:
	ECHO.
	ECHO.  1 - Go Back
	ECHO.
	ECHO.  2 - Open The Zip Up In The Mp4/Gif Converter
	ECHO.
	ECHO.  3 - Go Back To The Main Menu
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:123
	IF ERRORLEVEL 1 SET K=1
	IF ERRORLEVEL 2 SET K=2
	IF ERRORLEVEL 3 SET K=3
	IF %K%==1 (
		SET "savename=%filename:.zip=%"
		GOTO :JPGSETTINGS
	)
	IF %K%==2 (  
		RMDIR /q "%~dp0temp" %log%
		CALL :UNZIP "%madezipfolder%\!savename!.zip"
		SET "filename=!savename!"
		CALL :RESETVALUES
		SET savename=!filename:.zip=!
		SET /A filetype=1
		CALL :READDESC
		GOTO :YOURSETTINGS
	)
	IF %K%==3 (	
		%log% RMDIR /Q "%~dp0temp"
		GOTO :MAINMENUBA2MP4
	)
GOTO :MAINMENUBA2MP4


:YOURSETTINGS
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.
	ECHO. 1 - Continue, And Make %videotype%
	ECHO.
	ECHO. 2 - Continue, And Make %videotype% ^& Gif
	ECHO.
	ECHO. 3 - Change The Video Compression Level
	ECHO.
	ECHO. 4 - Change The Resolution ^(%width%x%height%^)
	ECHO.
	ECHO. 5 - Change The Fps
	ECHO.
	ECHO. 6 - Reload desc.txt    ^<^<reset fps/resolution/repeats^<^<
	ECHO.
	ECHO. 7 - Export As A Mp4 Style Bootanimation
	ECHO.
	ECHO. 8 - Go Back To The Main Menu
	ECHO.
	ECHO. 9 - Exit
	ECHO.
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:123456789
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF ERRORLEVEL 5 SET K=5
		IF ERRORLEVEL 6 SET K=6
		IF ERRORLEVEL 7 SET K=7
		IF ERRORLEVEL 8 SET K=8
		IF ERRORLEVEL 9 SET K=9
		IF %K%==1 GOTO :LETSDOIT
		IF %K%==2 SET "gif=true"&GOTO :LETSDOIT
		IF %K%==3 CALL :CHANGECRF
		IF %K%==4 CALL :CHANGERES
		IF %K%==5 CALL :CHANGEFPS
		IF %K%==6 CALL :READDESC
		IF %K%==7 CALL :AREYOUSURE&&GOTO :MOTOGX||GOTO :YOURSETTINGS
		IF %K%==8 GOTO :MAINMENUBA2MP4
		IF %K%==9 GOTO :FINISH
GOTO :YOURSETTINGS

:AREYOUSURE
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.Proceed with these settings?
	ECHO.
	ECHO.  1 - Proceed
	ECHO.
	ECHO.  2 - Go back
	ECHO.
	CHOICE /n /C:12
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF %K%==1 CLS&EXIT /B 0
		IF %K%==2 CLS&EXIT /B 55
GOTO :EOF
	
:CHANGECRF
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.The default crf value is 23.  You can set it all the way
	ECHO.to 0 for lossless compression.  Your video player more
	ECHO.than likely won't even play it.  Youtube will though!
	ECHO.
	ECHO.[Press enter to keep the default crf value of 23]
	ECHO._________________________________________________________
	ECHO.
	:LOOP3
	SET /p crf=What quality (0-51)? || SET /A crf=23
	2>NUL SET /A crf=%crf%/1 || GOTO :LOOP3
	IF %crf% LSS 0 GOTO :LOOP3
	IF %crf% GTR 51 GOTO :LOOP3
	SET "quality=%quality:~0,5%%crf%"
GOTO :EOF

:GETBA
	IF EXIST "%~dp0temp" RMDIR "%~dp0temp" /s /q
	CALL :DRAWHEADBA2MP4
	ECHO._________________________________________________________
	ECHO.The default location to get your %bootanimationfilename% is
	ECHO.%androidfolder%
	ECHO._________________________________________________________
	ECHO.
	ECHO.Please choose one of the following...
	ECHO.
	ECHO.  1 - Pull %bootanimationfilename% From /data/local/
	ECHO.
	ECHO.  2 - Specify A Different Location
	ECHO.
	ECHO.  3 - Specify A Different Filename ^& Location
	ECHO.
	ECHO.  4 - Go Back To The Main Menu
	ECHO.
	ECHO.  5 - Exit
	ECHO.
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:12345
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF ERRORLEVEL 5 SET K=5
		IF %K%==1 (SET "androidfolder=/data/local/"
			SET "filename=%bootanimationfilename%"
			CALL :PULLBA
			GOTO :EOF)
		IF %K%==2 CALL :NEWFOLDER
		IF %K%==3 CALL :NEWFOLDERANDFILE
		IF %K%==4 GOTO :MAINMENUBA2MP4
		IF %K%==5 GOTO :FINISH
GOTO :EOF	

:NEWFOLDER
	CALL :DRAWHEADBA2MP4
	ECHO.
	ECHO.Enter the location in the format of /folder/folder/
	ECHO.
	ECHO.OR /folder/ OR /folder/folder/folder/
	ECHO.
	:LOOP7
	SET /P androidfolder=: || GOTO :LOOP7
	SET "savename=bootanimation"
	SET "filename=%savename%.zip"
	CALL :PULLBA
GOTO :EOF

:NEWFOLDERANDFILE
	CALL :DRAWHEADBA2MP4
	ECHO.
	ECHO.Enter the location in the format of /folder/folder/
	ECHO.
	ECHO.OR /folder/ OR /folder/folder/folder/
	ECHO.
	:LOOP8
	SET /P androidfolder=: || GOTO :LOOP8
	ECHO.
	ECHO.Enter the name of the zip file
	ECHO.
	:LOOP9
	SET /P savename=: || GOTO :LOOP9
	SET "savename=%savename:.zip=%"
	SET "filename=%savename%.zip"
	CALL :PULLBA
GOTO :EOF

:PULLBA
	"%~dp0\bin\ADB" kill-server -d >NUL 2>&1
	ECHO.
	ECHO.
	ECHO.Pulling "%androidfolder%%filename%"...
	ECHO.
	"%~dp0\bin\ADB" pull %androidfolder%%filename% %filename%
	IF ERRORLEVEL 1 (cls
		ECHO.
		ECHO.THERE WAS AN ERROR!
		ECHO.
		ECHO.Either %filename% wasn't in %androidfolder%
		ECHO.
		ECHO.OR....
		ECHO.______________________________________________________
		ECHO.Adb is not properly connected.
		ECHO.
		ECHO.Try "Safely Removing" your device from your computer
		ECHO.
		ECHO.Then unplug your usb cable, and reinsert it.
		ECHO.______________________________________________________
		ECHO.
		ECHO.
		ECHO.Press any key to try again.
		ECHO.
		ECHO.
		PAUSE >NUL
		GOTO :GETBA
	)
GOTO :EOF
	
:DRAWHEADBA2MP4
	CLS
	ECHO.
	ECHO.______________________________________________________-_-	
	ECHO.
	ECHO.              Boot Animation 2 %videotype% v%vers%
	ECHO.
	ECHO._________________________________________________________
	ECHO.
	ECHO.                 Written by makers_mark
	ECHO.
	ECHO._________________________________________________________
	ECHO.
GOTO :EOF

:READDESC
	SET scale=
	SET crop=
	IF %filetype% EQU 1 (
		SET /A "bitrate=%defaultbitrate%"
		SET /a staticfoldercount$=0
		FOR /F "tokens=1-3 delims= " %%L IN ('FINDSTR /I "^[0-9]" "%~dp0temp\desc.txt"') DO CALL :GETRES %%L %%M %%N
		FOR /F "tokens=1-4 delims= " %%L IN ('FINDSTR /I "^P ^C" "%~dp0temp\desc.txt"') DO CALL :FOLDERS %%L %%M %%N %%O
		CALL :ORIGINALRES "!folder[1]!\!testfile!"
		IF NOT DEFINED qport CALL :FILLTHEVOID
		GOTO :EOF
	)

	SET /A staticfoldercount$=0
	SET /A index=1
	FOR /F "tokens=1-2 delims= " %%L IN ('FINDSTR /I "^[0-9]" "%~dp0temp\videodesc.txt"') DO CALL :VVARS %%L %%M %log%
	FOR /F "delims=" %%A IN ('dir /a-d-s-h%sort%/b "%~dp0temp\*.mp4"') DO (
		SET "mp4file[!index!]=%%A"
		SET /A index+=1
	)
	SET /A index-=1
	CALL :ORIGINALRES "!mp4file[1]!" V
	IF !index! NEQ !staticfoldercount$! (
		ECHO.
		ECHO.
		ECHO.There are !staticfoldercount$! descriptive lines in
		ECHO.the videodesc.txt file.  There are !index! video files
		ECHO.in the zip.  This is a problem.  Please look in the 
		ECHO.temp folder and see if you might see what has caused
		ECHO.this.  When you press a key the temp folder will be 
		ECHO.deleted and you will be at the main menu.
		PAUSE >NUL
		GOTO :MAINMENUBA2MP4
	)
	%log% SET /A vidwidth=%vidwidth%/1 || SET vidwidth=
	%log% SET /A vidheight=%vidheight%/1 || SET vidheight=
	%log% SET /A vidfps=%vidfps%/1 || SET vidfps=
	IF "%vidfps%"=="0" GOTO :VIDERROR
	IF "%vidwidth%"=="0" GOTO :VIDERROR
	IF "%vidheight%"=="0" GOTO :VIDERROR
	IF NOT DEFINED vidfps GOTO :VIDERROR
	IF NOT DEFINED vidwidth GOTO :VIDERROR
	IF NOT DEFINED vidheight GOTO :VIDERROR
	SET "width=%vidwidth%"
	SET "height=%vidheight%"
	SET "fps=%vidfps%"
	SET "fpsout=%fps%"
GOTO :EOF

:VIDERROR
	CALL :DRAWHEADBA2MP4
		ECHO.
		ECHO.There was an error reading the video parameters.
		ECHO.%filename%
		ECHO.Press any key to return to the Main Menu..
		ECHO.
		PAUSE>NUL
		GOTO :MAINMENUBA2MP4
:GOTO EOF

:VVARS
	SET /A staticfoldercount$+=1
	SET /A foldernamecount=%staticfoldercount$%-1
	SET foldertype[%staticfoldercount$%]=p
	SET /A folderrepeats[%staticfoldercount$%]=%1
	SET /A pauselastframe[%staticfoldercount$%]=%2
	SET folder[%staticfoldercount$%]=part!foldernamecount!
GOTO :EOF
		
:GETRES
	SET /A width=%1
	SET /A height=%2
	SET /A fps=%3
	SET /A fpsout=%fps%
GOTO :EOF

:FOLDERS
	SET /A staticfoldercount$+=1
	FOR /F "delims=" %%A IN ('DIR /a-d-s-h/b "%~dp0temp\%~4\*.*"^| FIND /v /c ""') DO SET /A filesinfolder[%staticfoldercount$%]=%%A
	SET foldertype[%staticfoldercount$%]=%1
	SET /A folderrepeats[%staticfoldercount$%]=%2
	SET /A motogx[%staticfoldercount$%]=%2
	SET /A pauselastframe[%staticfoldercount$%]=%3
	SET folder[%staticfoldercount$%]=%4
	SET /A frames[%staticfoldercount$%]=!filesinfolder[%staticfoldercount$%]! + !pauselastframe[%staticfoldercount$%]!
	CALL :GETEXT %staticfoldercount$%
GOTO :EOF

:GETEXT
	FOR /F "delims=" %%f IN ('dir /a-d-s-h/b "%~dp0temp\!folder[%~1]!\*.*"') DO (
		SET "ext=%%f"
		IF [%~1]==[1] IF NOT DEFINED testfile SET "testfile=!ext!"
		SET extinfolder[%~1]=!ext:~-3!
		GOTO :GETOUTAGAIN
	)
:GETOUTAGAIN
GOTO :EOF

:DUPENAME
	IF NOT EXIST "%~dp0%~1\!%~2!.%~3" (GOTO :EOF)
	SET /A unique=1
	:DUPE
		IF NOT EXIST "%~dp0%~1\!%~2!(%unique%).%~3" (
			SET "%~2=!%~2!(%unique%)"
			GOTO :EOF
		) ELSE (
			SET /A unique+=1
			GOTO :DUPE
		)
GOTO :EOF

:MOTOGX
	CALL :GETBITRATE
	IF NOT DEFINED scale SET "scale=scale=%width%:%height%"
	IF DEFINED crop SET "videofilters=-vf "%scale%,%crop%,fps=%fpsout%,format=%fformat%""
	IF NOT DEFINED crop SET "videofilters=-vf "%scale%,fps=%fpsout%,format=%fformat%""	
	CALL :DRAWSETTINGS
	IF NOT "%bitrate%"=="1"	SET "bitratestring=-b:v %bitrate%k"&SET "savename=%bitrate%kbs_%savename%"&SET "bufsize=-bufsize %bitrate%k"
	CALL :DUPENAME "%madezipfolder%" "savename" "zip"	
	SET "foldername=%savename%"
	CALL :DUPENAME "motogx" "foldername" 
	IF NOT EXIST "%~dp0motogx\%foldername%" MKDIR "%~dp0motogx\%foldername%"
	ECHO.
	SET /A checkheight=%height%%%2
	SET /A checkwidth=%width%%%2
	ECHO.
	ECHO.
	IF %checkheight% EQU 1 (SET /A height-=1 & ECHO.Height has been adjusted 1 pixel)
	IF %checkwidth% EQU 1 (SET /A width-=1	& ECHO.Width has been adjusted 1 pixel)
	ECHO.Working..
	FOR /L %%A IN (1,1,%staticfoldercount$%) DO (
		IF %%A LSS 10 (SET "motoname=0%%A") ELSE ("SET motoname=%%A")
		ECHO.%%A/!staticfoldercount$!...!folder[%%A]!..........
		CALL :RENUM "!folder[%%A]!" !extinfolder[%%A]! %log%
		%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% %stno% %stnorng% -f image2 -r %fps% -i "%~dp0temp\!folder[%%A]!\%renumprepend%%%05d.!extinfolder[%%A]!" -tune stillimage -c:v libx264 %videofilters% %bitratestring% %bufsize% -y "motogx\%foldername%\!motoname!_%motovidname%.mp4"||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :YOURSETTINGS)
		ECHO.!folder[%%A]! complete
		ECHO.!motogx[%%A]! !pauselastframe[%%A]!>>"%~dp0motogx\%foldername%\videodesc.txt"
	)
	IF %checkheight% EQU 1 SET /A height+=1
	IF %checkwidth% EQU 1 SET /A width+=1
	SET checkheight=
	SET checkwidth=
	%log% "%~dp0\bin\7ZA" a -y -r -tzip "%~dp0%madezipfolder%\%savename%.zip" "%~dp0motogx\%foldername%\*.*" -mx0
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	ECHO.Mp4 bootanimation zip saved in
	ECHO."%madezipfolder%\%savename%.zip"
	ECHO.
	ECHO.The unzipped contents can be found in this folder:
	ECHO."motogx\%foldername%"
	ECHO.
	ECHO.
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	ECHO.
	ECHO.Press any key to continue..
	ECHO.
	IF DEFINED autoopenfolder START "" "%~dp0%madezipfolder%\"
	ECHO.
	PAUSE >NUL
	SET bufsize=
	SET "savename=%filename:.zip=%"
GOTO :YOURSETTINGS

:GETBITRATE
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.If you have problems with the bootanimation not playing
	ECHO.
	ECHO.correctly you may try lowering the bit rate for the mp4
	ECHO.
	ECHO.
	ECHO.Just hit enter to use the default %defaultbitrate%kb/s
	ECHO.
	ECHO.
	ECHO.Enter '1' to not specify a bit rate.
	ECHO.
	ECHO.
	ECHO.The default bit rate was derived from observations of 
	ECHO.
	ECHO.stock Mp4 bootanimation bit rates at 24fps and a 
	ECHO.
	ECHO resolution of 720x1280.
	ECHO.
	:BITLOOP
	SET /P bitrate=: || SET /A bitrate=%defaultbitrate%
	2>NUL SET /A bitrate=%bitrate%/1 || GOTO :BITLOOP
	IF "%bitrate%"=="0" GOTO :BITLOOP
	SET "bitratestring=-b:v %bitrate%k"
	IF "%bitrate%"=="1" (SET "bitratestring=" & SET "bitrate=")
GOTO :EOF

:GIFSETTINGS
	IF NOT EXIST "%~dp0%gifsfolder%" MKDIR "%~dp0%gifsfolder%"
	CALL :DRAWSETTINGS
	ECHO.
	ECHO.
	ECHO.  1 - Make Gif The Same Size. (%width%x%height%)
	ECHO.
	ECHO.  2 - Specify A Different Resolution.
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:12
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF %K%==1 (
			SET "gifwidth=%width%"
			SET "gifheight=%height%"
			SET "outputtogif=-y %gifpixelformat%"
		)
		IF %K%==2 (
			CALL :DRAWSETTINGS
			ECHO.
			ECHO.You have to enter at least one value. Just pressing enter
			ECHO.
			ECHO.on either resolution will substitute a value in that will
			ECHO.
			ECHO.be a complement to the value you do enter, that will keep
			ECHO.
			ECHO.the aspect ratio the same. You have to enter at least
			ECHO.
			ECHO.one value though.  Example:
			ECHO.
			ECHO.You want a gif 300 pixels tall, and don't care what the 
			ECHO.
			ECHO.width is.  Just hit enter when prompted for width.  And
			ECHO.
			ECHO.enter 300 for height.  The width will be adjusted to 
			ECHO.
			ECHO.accomodate the same aspect ratio.
			ECHO.
			ECHO.[enter 'x' to start over]		video: %width%x%height%
			ECHO._________________________________________________________			
			:LOOP14
			ECHO.
			SET /P gifwidth=Width: || SET /A "gifwidth=-1"
			IF /i "%gifwidth%"=="x" GOTO :LOOP14
			2>NUL SET /A gifwidth=!gifwidth!/1 || GOTO :LOOP14
			IF "!gifwidth!"=="0" GOTO :LOOP14
			:LOOP15
			SET /P gifheight=Height: || IF "!gifwidth!"=="-1" (GOTO :LOOP15) ELSE (SET /A "gifheight=-1")
			IF /i "%gifheight%"=="x" GOTO :LOOP14
			2>NUL SET /A gifheight=!gifheight!/1 || GOTO :LOOP 15
			IF "!gifheight!"=="0" GOTO :LOOP15
			IF "!gifwidth!"=="-1" IF "!gifheight!"=="-1" GOTO :LOOP14
			SET "outputtogif=-y %gifpixelformat% -vf "scale=!gifwidth!:!gifheight!""
		)
	CALL :GIFSAVENAME
	CALL :DUPENAME "%gifsfolder%" "gifsavename" "gif"
	SET "outputtogif=%outputtogif% "%~dp0%gifsfolder%\!gifsavename!.gif""
	CALL :DRAWSETTINGS
GOTO :EOF

:LETSDOIT
	CALL :DRAWSETTINGS
	IF NOT DEFINED scale SET "scale=scale=%width%:%height%"
	IF DEFINED crop (SET "videofilters=-vf "%scale%,%crop%,fps=%fpsout%,format=%fformat%"") ELSE (SET "videofilters=-vf "%scale%,fps=%fpsout%,format=%fformat%"")
	%log% CALL :CLEARBUFF
	IF DEFINED gif CALL :GIFSETTINGS
	IF NOT DEFINED gorighttovideo (
		CALL :NAMEPREFIX
		CALL :DUPENAME "%savefolder%" "savename" "%videotype%"
	)
	SET /A checkheight=%height%%%2
	SET /A checkwidth=%width%%%2
	IF %checkheight% EQU 1 (SET /A height-=1 & ECHO.Height has been adjusted 1 pixel)
	IF %checkwidth% EQU 1 (SET /A width-=1	& ECHO.Width has been adjusted 1 pixel)
	ECHO.
	ECHO.
	ECHO.Working..
	FOR /L %%A IN (1,1,%staticfoldercount$%) DO (	
		ECHO.%%A/!staticfoldercount$!...!folder[%%A]!..........
		IF !pauselastframe[%%A]! GEQ 1 CALL :COPYREPEATEDFRAMES %%A %log%
		CALL :RENUM "!folder[%%A]!" !extinfolder[%%A]! %log%
		%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% %stno% %stnorng% -f image2 -r %fps% -i "%~dp0temp\!folder[%%A]!\%renumprepend%%%05d.!extinfolder[%%A]!" -tune stillimage -c:v libx264 %videofilters% %quality% -y "%~dp0temp\buffer\%%A%savename%.%videotype%"||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :OUT)
		ECHO.!folder[%%A]! complete
		IF !pauselastframe[%%A]! GEQ 1 CALL :TRIMFRAMES %%A %log%
		SET "awayaroundeverything=file '%~dp0temp\buffer\%%A%savename%.%videotype%'"
		FOR /L %%J in (1,1,!folderrepeats[%%A]!) DO ECHO.!awayaroundeverything!>>"%~dp0copylist"
	)
	IF %checkheight% EQU 1 SET /A height+=1
	IF %checkwidth% EQU 1 SET /A width+=1
	SET checkheight=
	SET checkwidth=
GOTO :FINISHVIDEO

:TRIMFRAMES
	SET /A piks=!filesinfolder[%~1]!
	FOR /F "skip=%piks% eol=: delims=" %%F IN ('dir /a-d-h/b/on "%~dp0temp\!folder[%~1]!\*.!extinfolder[%~1]!"') DO DEL /Q "%~dp0temp\!folder[%~1]!\%%F"
GOTO :EOF

:COPYREPEATEDFRAMES
	FOR /F "delims=" %%t IN ('dir /a-d-h/on/b "%~dp0temp\!folder[%~1]!\*.!extinfolder[%~1]!"') DO SET "filetocopy=%%t"
	FOR /L %%Y IN (1,1,!pauselastframe[%~1]!) DO COPY "%~dp0temp\!folder[%~1]!\%filetocopy%" "%~dp0temp\!folder[%~1]!\z%%Y%filetocopy%"
GOTO :EOF

:NAMEVIDZ
	SET "savename=%fps%_%width%X%height%_q%jpegquality%_%savename%"
GOTO :EOF

:GIFSAVENAME
	IF "%gifwidth%" EQU "-1" (
		SET "gifsavename=%fps%_wx%gifheight%_%savename%"
		GOTO :EOF
	)
	IF "%gifheight%" EQU "-1" (
		SET "gifsavename=%fps%_%gifwidth%xh_%savename%"
		GOTO :EOF
	)
	SET "gifsavename=%fps%_%gifwidth%x%gifheight%_%savename%"
GOTO :EOF
	
:NAMEPREFIX
	SET "savename=%fps%_%fpsout%_%width%x%height%crf%quality:~-2%_%savename%"
GOTO :EOF

:FINISHVIDEO
	%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% -f concat -i "%~dp0copylist" -vcodec copy -y "%~dp0%savefolder%\%savename%.%videotype%" %outputtogif%||(CALL :FFVIEW&SET "savename=%filename:.zip=%"&GOTO :OUT)
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	IF DEFINED gorighttovideo (
		ECHO.Converted Zip saved in "%madezipfolder%"
		ECHO.as "%filename%"
		ECHO._________________________________________________________
		ECHO.
	)
	ECHO.Video saved in "%savefolder%"
	ECHO.as "%savename%.%videotype%"
	IF DEFINED outputtogif (
		IF DEFINED autoopengif START "" "%~dp0%gifsfolder%\%gifsavename%.gif"
		ECHO._________________________________________________________
		ECHO.Gif saved as:\%gifsfolder%\
		IF EXIST "%~dp0%gifsfolder%\%gifsavename%.gif" ECHO."%gifsavename%.gif"
		ECHO.
		SET outputtogif=
		SET gif=
		SET gifwidth=
		SET gifheight=
		SET gifsavename=
	)	
	ECHO.
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	IF DEFINED autoopen START "" /max /realtime "%~dp0%savefolder%\%savename%.%videotype%"
	SET "savename=%filename:.zip=%"
	ECHO.Press a key to continue..
	PAUSE >NUL
	%log% CALL :CLEARBUFF
	DEL "%~dp0copylist" /Q %log%
	:OUT
	IF DEFINED gorighttovideo (
		SET gorighttovideo=
		%log% CALL :CLEARBUFF
		RMDIR /s /q "%~dp0temp"
		SET "filename=!returnfilename!"
		CALL :UNZIP "%originatingfolder%\!filename!"
		CALL :RESETVALUES
		SET "savename=!filename:.zip=!"
		SET /A filetype=2
		CALL :READDESC
		GOTO :JPGSETTINGS
	)
GOTO :YOURSETTINGS

:CONCATALL
	>NUL (DIR /A-D-S-H/B "%~dp0%savefolder%\*.%videotype%" | FINDSTR "^") || GOTO :MAINMENUBA2MP4
	IF EXIST "%~dp0copylist" DEL "%~dp0copylist" /Q %log%
	CALL :DRAWHEADBA2MP4
	ECHO.
	ECHO._________________________________________________________
	ECHO.
	ECHO.This will put all videos together that are currently in 
	ECHO.
	ECHO.the folder videos\  You might experience errors with
	ECHO.
	ECHO.the video or no video produced if the resolutions are
	ECHO.
	ECHO.different on a video to video comparison basis.
	ECHO._________________________________________________________
	ECHO.I highly recommend you to hit option 2 to only use
	ECHO.
	ECHO.%videotype%'s that share a common string in the name.
	ECHO._________________________________________________________
	ECHO.
	ECHO. 1 - Concatenate ALL Videos
	ECHO.
	ECHO. 2 - Concatenate Videos With A Common String In Name
	ECHO.
	ECHO. 3 - Go To The Main Menu
	ECHO.
	ECHO. 4 - Exit
	ECHO.
	CHOICE /n /m "Please Select A Menu Number:" /C:1234
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF %K%==1 CALL :ALL
		IF %K%==2 CALL :SOME
		IF %K%==3 GOTO :MAINMENUBA2MP4
		IF %K%==4 GOTO :FINISH
GOTO :MAINMENUBA2MP4

:SOME
	SET strang=
	CALL :DRAWHEADBA2MP4
	SET /a index=0
	FOR /F "delims=" %%E in ('dir "%~dp0%savefolder%\*.%videotype%" /a-d-h /b') DO (
		SET /A index+=1
		SET "videofile[!index!]=%%E"
		)
	ECHO._________________________________________________________
	FOR /l %%I in (1,1,%index%) DO ECHO.!videofile[%%I]!
	ECHO._________________________________________________________

	ECHO.
	ECHO.Please enter a search string.  I will put together all
	ECHO.
	ECHO.the files that contain whatever you type.  Don't mix 
	ECHO.
	ECHO.files with different compression settings, and in some
	ECHO.
	ECHO.cases resolutions.  The compression setting value for
	ECHO.
	ECHO.each file can be found right after the resolution in the
	ECHO.
	ECHO.the file name.  Default is crf 23.
	ECHO.
	ECHO.An idea for a search string is the resolution...
	ECHO.or the crf value.....
	ECHO.
:TRYITAGAIN
	SET /P strang=: || GOTO :TRYITAGAIN
	ECHO.
	FOR /F "delims=" %%E IN ('dir /a-d-h /b "%~dp0%savefolder%\*.%videotype%"^|findstr /rmic:"%strang%"') DO (
		SET "awayaroundeverything=file '%~dp0%savefolder%\%%E'"
		ECHO.!awayaroundeverything!>>"%~dp0copylist"
		ECHO.Added:%%E
	)
	IF NOT EXIST "%~dp0copylist" GOTO :TRYITAGAIN
	ECHO._________________________________________________________
	ECHO.
	ECHO.These are the files matching: %strang%
	ECHO.
	ECHO. 1 - Go back to the main menu
	ECHO.
	ECHO. 2 - Continue
	ECHO.
		CHOICE /n /m "Please Select A Menu Number:"  /C:12
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF %K%==1 GOTO :MAINMENUBA2MP4
		IF %K%==2 CALL :NAMECONCATALL %strang%
	CALL :MAKECONCAT
GOTO :MAINMENUBA2MP4

:ALL
	FOR /F "delims=" %%E IN ('dir "%~dp0%savefolder%\*.%videotype%" /a-d-h /b') DO (
		SET "awayaroundeverything=file '%~dp0%savefolder%\%%E'"
		ECHO.!awayaroundeverything!>>"%~dp0copylist"
		ECHO.Added:%%E
	)
	CALL :NAMECONCATALL
	CALL :MAKECONCAT
GOTO :MAINMENUBA2MP4

:MAKECONCAT
	IF NOT EXIST "%~dp0copylist" GOTO :EOF
	ECHO.
	ECHO._________________________________________________________
	ECHO.
	%log% "%~dp0\bin\FFMPEG" %ffdebug% %ffshowb% -f concat -i "%~dp0copylist" -vcodec copy -y "%~dp0%savefolder%\%savename%.%videotype%"||(CALL :FFVIEW&GOTO :CONCATALL)
	ECHO.______________________________________________________-_-
	ECHO.
	ECHO.\\\\\\\\\\\\\\\\\\\\\\\\\\DONE///////////////////////////
	ECHO.
	ECHO.Saved as:%savefolder%\%savename%.%videotype%
	ECHO.
	ECHO.
	ECHO.//////////////////////////DONE\\\\\\\\\\\\\\\\\\\\\\\\\\\
	ECHO._________________________________________________________
	ECHO.
	ECHO.Press any key to return to the main menu..
	PAUSE >NUL	
	DEL /q "%~dp0copylist"
GOTO :MAINMENUBA2MP4
	
:RENUM
	SET "index=00000"
	SET /A Q=1%index%
	FOR /F "delims=" %%a IN ('dir /a-d-h %sort% /b "%~dp0temp\%~1\*.%~2"') DO (
		SET /a Q+=1
		REN "%~dp0temp\%~1\%%~a" "%renumprepend%!Q:~-5!%%~xa"
	)
GOTO :EOF

:UNZIP
	DEL /Q "%~dp0temp\*.txt" >NUL 2>&1
	IF NOT EXIST "%~dp0temp\buffer" MKDIR "%~dp0temp\buffer"
	"%~dp0\bin\7ZA" -y x "%~dp0%~1" -o"%~dp0temp" %log%
	IF NOT EXIST "%~dp0temp\desc.txt" IF NOT EXIST "%~dp0temp\videodesc.txt" (
		MKDIR "%~dp0fztemp" %log%
		SET /A count=0
			FOR /F "delims=" %%i IN ('DIR /S/B/A-D "%~dp0temp\*.zip"') do (
				SET /A count+=1
				MOVE "%%~fi" "%~dp0fztemp\%%~nxi" %log%
				SET "zipfile[!count!]=%%~nxi"
			)
		RMDIR /S/Q "%~dp0temp" && MKDIR "%~dp0temp"
		MOVE "%~dp0fztemp\*.zip" "%~dp0temp" %log%
			IF !count! EQU 1 (
				"%~dp0\bin\7ZA" -y x "%~dp0temp\!zipfile[1]!" -o"%~dp0temp" %log%
				DEL /S/Q "%~dp0temp\!zipfile[1]!" %log%
				SET "filename=!zipfile[1]!"
				RMDIR /S/Q "%~dp0fztemp" %log%
			)
			IF !count! GTR 1 (
					CALL :DRAWHEADBA2MP4
					ECHO.
					ECHO.Multiple zips were found embedded in:
					ECHO."%~1"
					ECHO.
					ECHO.Please choose one.
					ECHO._________________________________________________________	
					ECHO.
					FOR /l %%I in (1,1,!count!) DO IF %%I LSS 10 (ECHO. %%I. !zipfile[%%I]!) ELSE (ECHO.%%I. !zipfile[%%I]!)
					ECHO.
				  :LOOPAGE
					SET /p pickazip=: || GOTO :LOOPAGE
					2>NUL SET /A pickazip=!pickazip!/1
					IF !pickazip! LSS 1 GOTO :LOOPAGE
					IF !pickazip! GTR !count! GOTO :LOOPAGE
					CALL SET "filename=%%zipfile[!pickazip!]%%"
					ATTRIB +h "%~dp0temp\!filename!" %log%
					DEL /S /Q "%~dp0temp\*.zip" %log%
					ATTRIB -h "%~dp0temp\!filename!" %log%
					"%~dp0\bin\7ZA" -y x "%~dp0temp\!filename!" -o"%~dp0temp" %log%
					DEL /S /Q "%~dp0temp\!filename!" %log%
					RMDIR /S /Q "%~dp0fztemp" %log%
			)
		)
	IF NOT EXIST "%~dp0temp\desc.txt" IF NOT EXIST "%~dp0temp\videodesc.txt" (
				CALL :DRAWHEADBA2MP4
				ECHO.
				ECHO._________________________________________________________		
				ECHO.
				ECHO.There isn't a desc.txt or videodesc.txt in that zip...
				ECHO.
				ECHO.Error was with the following zip file.
				ECHO.
				ECHO."!filename!"
				ECHO.
				ECHO.Which was inside of:
				ECHO.
				ECHO."%~1"
				ECHO.
				ECHO.Press any key to continue to the main menu.
				ECHO.
				PAUSE >NUL
				RMDIR "%~dp0temp" /s /q %log%
				GOTO :MAINMENUBA2MP4
	)
	IF EXIST "%~dp0temp\desc.txt" SET /A filetype=1
	IF EXIST "%~dp0temp\videodesc.txt" SET /A filetype=2
GOTO :EOF

:NAMECONCATALL
	SET savename=%TIME::=_%
	SET savename=%savename:.=%
	SET savename=%savename: =%
	SET savename=%~1%savename%CC
GOTO :EOF

:FFVIEW
	ECHO.
	ECHO.
	ECHO._________________________________________________________	
	ECHO.
	ECHO.
	ECHO.
	ECHO.There was an error within FFmpeg.
	ECHO.
	ECHO.Please check towards the end of the log file to determine
	ECHO.
	ECHO.the problem.
	ECHO.
	ECHO.  1 - Open Log File
	ECHO.
	ECHO.  2 - Go Back
	ECHO.
	ECHO.  3 - Go To The Main Menu
	ECHO.
	ECHO.  4 - Exit
	ECHO.
		CHOICE /n /m "Please Select A Menu Number:"  /C:1234
		IF ERRORLEVEL 1 SET K=1
		IF ERRORLEVEL 2 SET K=2
		IF ERRORLEVEL 3 SET K=3
		IF ERRORLEVEL 4 SET K=4
		IF %K%==1 START "" "%~dp0log.txt"&GOTO :EOF
		IF %K%==2 GOTO :EOF
		IF %K%==3 GOTO :MAINMENUBA2MP4
		IF %K%==4 GOTO :FINISH
GOTO :MAINMENUBA2MP4
	
:FINISH
	"%~dp0\bin\ADB" kill-server -d >NUL 2>&1
	IF EXIST "%~dp0temp" RMDIR "%~dp0temp" /s /q
	ENDLOCAL
EXIT
