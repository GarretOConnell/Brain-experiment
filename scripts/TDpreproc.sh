# Rename files and stuff
exp_folder=$(pwd)
subjlist=(1 2 3 6 8 9 10 12 13 16 17 18 19 20 21 22 23 24 25 29 30 31 34 35 36 37 38 40 41 42 45 47 48 49 50)
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
#feat_dir="mvpa"
out_dir="s8"
SMOOTH=8
for part_index in $(eval echo "{0..$part_no}")
	do
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber
	subject_dir=$exp_folder/subj$subjectnumber
	cd ${subject_dir}
	rm -rf ./tdrun*
	td_files=($(ls -d ./raw/TDrun*preproc* ))
	check1=($(echo ${td_files[0]} | grep -o -P 'run.{0,1}'| sed -e "s/^.*\(.\)$/\1/")) # check run number
	check2=($(echo ${td_files[1]} | grep -o -P 'run.{0,1}'| sed -e "s/^.*\(.\)$/\1/"))
	run_no=$(echo $((${#td_files[*]}-1)))

	for run_index in $(eval echo "{0..$run_no}"); do
		run=$(grep -o "[0-9]" <<<"${td_files[run_index]}") # convert linear index to filename index

		FSLDATADIR=$subject_dir
		OUTPUT=${FSLDATADIR}/tdrun$run-$out_dir.feat
		ANATFILE=${FSLDATADIR}/raw/T1_nodif_brain
		DATA=${FSLDATADIR}/raw/TDrun$run-preproc
		vols=($(fslstats -t ${FSLDATADIR}/raw/TDrun$run-preproc.nii.gz -x))
		VOLNO=$(echo $((${#vols[@]}/3)))
		echo $OUTPUT
		#makes the fsf files from the template fsf file
		sed -e 's@OUTPUT@'$OUTPUT/'@g' -e 's@ANAT@'$ANATFILE'@g' -e 's@DATA@'$DATA'@g' -e 's@VOLNO@'$VOLNO'@g' -e 's@SMOOTH@'$SMOOTH'@g' ../designs/td_fsl_preproc/td-firstlevel.fsf > $FSLDATADIR/raw/design.fsf

		feat $FSLDATADIR/raw/design.fsf
		mv ${subject_dir}/raw/TDrun$run-preproc.feat ./tdrun$run-$out_dir.feat
	done
done
