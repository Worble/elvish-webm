# webm.elv
script_name='webm.vpy'
temp_script=$E:XDG_RUNTIME_DIR'/'$script_name
name = ''

fn open_vsedit [input_file]{	
	name=$input_file
	file=(path-abs $input_file)
	script='/home/worble/.vapoursynth/scripts/'$script_name
	tempdir=$E:XDG_RUNTIME_DIR'/'$input_file'.ffindex'

	cp $script $E:XDG_RUNTIME_DIR
	sed -ie 's|{source}|'$file'|g' $temp_script
	sed -ie 's|{tempdir}|'$tempdir'|g' $temp_script
	vsedit $temp_script
}

fn encode_webm [&crf=30 &qmin=0 &qmax=63]{
	if (not ?(test -n $name)) {
		fail "No filename for output - have you run open_vsedit?" 
	}

	#pass 1
	vspipe $temp_script - --y4m | ffmpeg -i - -c:v libvpx -b:v 0 -crf $crf -pass 1 -an -f webm -y -passlogfile $E:XDG_RUNTIME_DIR/ffmpeg2pass /dev/null
	
	#pass 2
	vspipe $temp_script - --y4m | ffmpeg -f yuv4mpegpipe -i - -c:v libvpx -b:v 0 -crf $crf -an -qmin $qmin -qmax $qmax -passlogfile $E:XDG_RUNTIME_DIR/ffmpeg2pass -pass 2 ~/Videos/$name.webm
}
