exp_folder=$(pwd)
subjlist= #(1 2 8 9 10 12 13 16 18 19 21 23 38 41 42 43) # 3 6 22 24 26 29 30 33 34 35 36 40 48 49 50) #
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
output_dir='tom-ppi.feat'
series_dir='tom-ppi.gfeat/tom-ppi-timeseries-rTPJ'
design='tom_fsl_preproc_A_ppi'
SMOOTH=5
p_thresh=0.05
z_thresh=2.3
# ptoz 0.05 # convert p value to z threshold

for part_index in $(eval echo "{0..$part_no}"); do
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber	
	subject_dir=$exp_folder/subj$subjectnumber
	cd ${subject_dir}
	subjectnumber=${subjlist[part_index]}
	FSLDATADIR=$exp_folder/subj$subjectnumber	
	OUTPUT=$exp_folder/subj$subjectnumber/$output_dir
	ANATFILE=${FSLDATADIR}/raw/T1_nodif_brain
	DATA=${FSLDATADIR}/raw/tom_grefield	
	vols=($(fslstats -t ${FSLDATADIR}/raw/tom_grefield.nii.gz -x))
	VOLNO=$(echo $((${#vols[@]}/3)))	
	
	# PPI
	SERIES=$exp_folder/$series_dir/$subjectnumber-timecourse.txt
	
	# remove previous
	rm -r $subject_dir/$output_dir	

	#makes the fsf files from the template fsf file
	sed -e 's@OUTPUT@'$OUTPUT'@g' -e 's@ANAT@'$ANATFILE'@g' -e 's@DATA@'$DATA'@g' -e 's@VOLNO@'$VOLNO'@g' -e 's@SMOOTH@'$SMOOTH'@g' -e 's@p_thresh@'$p_thresh'@g' -e 's@z_thresh@'$z_thresh'@g' -e 's@SERIES@'$SERIES'@g' ../designs/$design/$design.fsf > $FSLDATADIR/raw/design.fsf
	feat $FSLDATADIR/raw/design.fsf
done	


