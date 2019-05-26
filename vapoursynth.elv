# vapoursynth.elv
script_name='input.vpy'
temp_script=$E:XDG_RUNTIME_DIR'/'$script_name
name = ''

fn open_vsedit [input_file]{	
	name=(echo $input_file | cut -f 1 -d '.')
	file=(path-abs $input_file)
	script=$E:HOME'/.vapoursynth/scripts/'$script_name
	tempdir=$E:XDG_RUNTIME_DIR'/'$name'.ffindex'

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

fn output_images [number]{
	folder_location=$E:HOME'/Pictures/Stitches/NewFolder'
	
	if (not ?(test -n $name)) {
		fail "No filename for output - have you run open_vsedit?" 
	}

	if (not ?(test -d $folder_location)) {
		mkdir -p $folder_location
	}
	vspipe $temp_script - --y4m | ffmpeg -i - $folder_location/$name'_'$number'_'%04d.png -hide_banner
}
