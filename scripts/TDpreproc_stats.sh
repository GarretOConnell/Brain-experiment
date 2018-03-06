exp_folder=$(pwd) 
subjlist=(1 3 6 8 9 10 12 18 22 23 24 30 35 36 38 41 42 48 49) 
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
output_dir='tdother-imm-s5-vmPFC-ppi.feat'
input_dir='tdother-s5.feat'
cond_of_interest='other'
ev_of_interest='imm'
data_file='filtered_func_data'
td_of_interest_global=1 # 1 for other, 2 for self
td_of_interest_switch=2 # 2 for other, 1 for self
design='td_fsl_preproc_stats_ppi'
SMOOTH=5
p_thresh=0.05
z_thresh=2.3
mask="tdother-s8.feat/tom2tdself-rTPJ-conservative"
# ptoz 0.05 # convert p value to z threshold
tdscan_files=($(ls -d ./tdscan/tdscan* ))
for part_index in $(eval echo "{0..$part_no}"); do
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber		
	subject_dir=$exp_folder/subj$subjectnumber

	tdscan_run=($(echo ${tdscan_files[@]} | grep -o -P "subj${subjectnumber}_.{0,1}" | tail -c 2))	
	if [ $tdscan_run -eq 2 ] 
		then 
		td_of_interest=$td_of_interest_switch
	else
		td_of_interest=$td_of_interest_global
	fi	
	cd ${subject_dir}
	FSLDATADIR=$exp_folder/subj$subjectnumber	
	OUTPUT=${FSLDATADIR}/$output_dir
	ANATFILE=${FSLDATADIR}/raw/T1_nodif_brain
	DATA=${FSLDATADIR}/$input_dir/${data_file} #${td_of_interest}-preproc.nii.gz
	vols=($(fslstats -t ${FSLDATADIR}/raw/TDrun$td_of_interest-preproc.nii.gz -x))
	VOLNO=$(echo $((${#vols[@]}/3)))	
	CUSTOM_IMM=$exp_folder/designs/td${cond_of_interest}_imm_$subjectnumber
	CUSTOM_DEL=$exp_folder/designs/td${cond_of_interest}_del_$subjectnumber	
	CUSTOM_TIME=$exp_folder/designs/$subjectnumber-timecourse.txt
	MASK=${FSLDATADIR}/$mask
	#CUSTOM_COND=$exp_folder/designs/td${cond_of_interest}_cond_$subjectnumber
	#CUSTOM_BASE=$exp_folder/designs/td${cond_of_interest}_base_$subjectnumber
	CUSTOM_EV=$exp_folder/designs/td${cond_of_interest}_${ev_of_interest}_$subjectnumber


	#makes the fsf files from the template fsf file
	sed -e 's@OUTPUT@'$OUTPUT'@g' -e 's@ANAT@'$ANATFILE'@g' -e 's@DATA@'$DATA'@g' -e 's@VOLNO@'$VOLNO'@g' -e 's@SMOOTH@'$SMOOTH'@g' -e 's@p_thresh@'$p_thresh'@g' -e 's@z_thresh@'$z_thresh'@g' -e 's@CUSTOM_IMM@'$CUSTOM_IMM'@g' -e 's@CUSTOM_DEL@'$CUSTOM_DEL'@g' -e 's@CUSTOM_EV@'$CUSTOM_EV'@g' -e 's@CUSTOM_TIME@'$CUSTOM_TIME'@g' -e 's@MASK@'$MASK'@g' ../designs/$design.fsf > $FSLDATADIR/raw/$design.fsf
	#sed -e 's@OUTPUT@'$OUTPUT'@g' -e 's@ANAT@'$ANATFILE'@g' -e 's@DATA@'$DATA'@g' -e 's@VOLNO@'$VOLNO'@g' -e 's@SMOOTH@'$SMOOTH'@g' -e 's@p_thresh@'$p_thresh'@g' -e 's@z_thresh@'$z_thresh'@g' -e 's@CUSTOM_COND@'$CUSTOM_COND'@g' -e 's@CUSTOM_BASE@'$CUSTOM_BASE'@g' ../designs/$design.fsf > $FSLDATADIR/raw/$design.fsf

	#rm -rf $subject_dir/raw/*.feat
	rm -rf $subject_dir/$output_dir
	feat $FSLDATADIR/raw/$design.fsf	
	#mv $subject_dir/tdself-s5-vmPFC-ppi.feat $subject_dir/tdself-del-s5-vmPFC-ppi.feat
	#mv $subject_dir/tdother-s5-vmPFC-ppi.feat $subject_dir/tdother-del-s5-vmPFC-ppi.feat

done	


