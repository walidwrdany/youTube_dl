@echo off

setlocal EnableDelayedExpansion
chcp 65001


REM ( ͡° ͜ʖ ͡°)


:------------------------------------------------------------


	echo.Loading...
	
	for /f "tokens=*" %%a in ('yt-dlp.exe --version') do ( set "youtube_version=%%a" )
	for /f "tokens=*" %%a in ('ffmpeg.exe -version') do ( set "ffmpeg_version=%%a" )
	
	
	set "current_directory=%~1"
	set "config_txt=%tmp%\yt-dlp-config.txt"
	set "format_txt=%tmp%\yt-dlp-formats.txt"
	set "archive_txt=%~dp0\archive.txt"

:------------------------------------------------------------


:Start

	
	call :Desplay

	set /p "url=Link :"
	set /p "index=Index :"
	echo.
	echo.
	
	if not defined index (
		set index=1
	)
	
	
	yt-dlp.exe --list-formats --playlist-items %index% %url% > %format_txt%
	yt-dlp.exe -v --list-formats --playlist-items %index% %url%
	

	findstr /i /r /c:"playlist" "%format_txt%" >nul && (
		set isPlayList=Yes
	) || (
		set isPlayList=No
	)

:------------------------------------------------------------


:Loop


	echo.
	echo.
	set /p "formatCode=Format Code :"
	set codeStatus=


	findstr /i /r /c:"^%formatCode%\>" "%format_txt%" >nul && (
		if not defined codeStatus findstr /I /R /C:"^%formatCode% .*audio" "%format_txt%" >nul && (set codeStatus=AUDIO ONLY)
		if not defined codeStatus findstr /I /R /C:"^%formatCode% .*video" "%format_txt%" >nul && (set codeStatus=VIDEO ONLY)
		if not defined codeStatus findstr /I /R /C:"^%formatCode% .*best" "%format_txt%" >nul && (set codeStatus=BEST OPTION)
	) || (
		set codeStatus=CUSTOM FORMAT
	)
	
	
	if not defined codeStatus (
		
		set "Mess=You choice '%formatCode%' | Are you Sure"
		
	) else (
		
		set "Mess=You choice '%formatCode%' and this is | %codeStatus% | Are you Sure"
		
	)


	echo.
	choice /C YN /M "%Mess%"
	echo.
	if %errorlevel%==1 goto :Download

	goto :Loop


:------------------------------------------------------------


:Download

	
	if exist "%config_txt%" del "%config_txt%"
	
	set baseOut=%current_directory%\%%(extractor)s
	set download_folder_audio=%baseOut%\Audio\
	set download_folder_videos=%baseOut%\Video\
	set playlist=%%(channel)s\%%(playlist)s
	set output=%%(playlist_index^|)03d%%(playlist_index^& - ^|)s%%(title)s.%%(ext)s

	(

		echo.# Lines starting with # are comments
		echo.# https://github.com/yt-dlp/yt-dlp
		echo.
		echo.
		echo.--console-title
		echo.--embed-thumbnail
		echo.--no-overwrites
		echo.--yes-playlist
		echo.--download-archive "%archive_txt%"
		REM echo.--no-embed-info-json
		REM echo.--proxy socks5://127.0.0.1:9150/
		echo.


		if defined formatCode (
			echo.--format "%formatCode%/bestvideo[ext=mp4][height<=?720]+bestaudio[ext=m4a]/best[ext=mp4][height<=?720]/best"
		) else (
			echo.--format "bestvideo[ext=mp4][height<=?720]+bestaudio[ext=m4a]/best[ext=mp4][height<=?720]/best"
		)

		echo.%codeStatus% | findstr /I /R /C:"AUDIO" >nul && (

			echo.--metadata-from-title "%%(artist)s - %%(title)s"
			echo.--extract-audio
			echo.--audio-format mp3
			echo.--audio-quality 0

			if "%isPlayList%"=="Yes" (
				echo.--output "%download_folder_audio%\%playlist%\%output%"
			) else (
				echo.--output "%download_folder_audio%\%output%"
			)

		) || (

			echo.--embed-metadata
			echo.--merge-output-format mp4
			echo.--xattrs
			REM echo.--embed-subs
			REM echo.--write-description

			if "%isPlayList%"=="Yes" (
				echo.--output "%download_folder_videos%\%playlist%\%output%"
			) else (
				echo.--output "%download_folder_videos%\%output%"
			)

		)

	) >> "%config_txt%"


	
	
	yt-dlp.exe -v --config-location "%config_txt%" %url%
	
	

:------------------------------------------------------------


:ReStart
	echo.
	echo.
	pause
	goto :Start
	

:------------------------------------------------------------


:Desplay

	set "Modified=%~t0"
	set Version=!Modified:~6,4!.!Modified:~0,2!.!Modified:~3,2!

	cls
	echo.
	echo.           youtube-dl is a command-line program to download videos from youTube and a few more sites
	echo.                       ffmpeg version %ffmpeg_version%
	echo.                          yt-dlp version %youtube_version%   updated !Version!
	echo.
	echo.
	goto :eof


:------------------------------------------------------------


:Exit
	echo.
	pause
	exit


:------------------------------------------------------------










