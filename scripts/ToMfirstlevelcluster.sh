exp_folder=$(pwd)
baselist=(12 13 14 15 17 18 20 21 22 23 26 28 31 38 54 55 58 71 73 74 76 77 78 80 81 82 84 85 90 92 94 95 101) # rTPJ
crosslist=(12 13 14 15 17 18 20 21 22 23 26 160 972 174 241 1014 657 843 971 672 180 1018 182 1059 335 412 749 398 951 1056 94 95 101) 
#subjlist=(1 2 3 6 8 9 10 12 13 16 18 21 22 23 26 29 30 33 34 35 38 40 41 42 43 48 49 50) # lTPJ
#subjlist=(1 2 3 6 8 9 10 12 13 14 16 21 23 24 26 29 30 32 33 34 35 36 38 40 41 42 43 48 49 50) # precuneus
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
#output_dir='tom-s8.feat'
#z_thresh=5.2
#z_thresh_name=52
feat_dir='vmPFC'
func_dir="tdother-s5.feat"
#td_oi="tdself"
#mask="tom2tdself-rTPJ-conservative"
#cluster_mask='cluster_mask_zstat1'
# ptoz 0.05 # convert p value to z threshold
	
for part_index in $(eval echo "{0..$part_no}"); do
	#subjectnumber=${subjlist[part_index]}
	crossnumber=${crosslist[part_index]}
	basenumber=${baselist[part_index]}
	echo $subjectnumber	
	#subject_dir=$exp_folder/${subjectnumber}
	cross_dir=$exp_folder/$crosslisnumber-TIME-1_fs_edit.long.$subjectnumber_BASE
	#cd ${subject_dir}
	#cope_index=$(($part_index+1))

	cp $subject_dir/tom-s8.feat/featquery-rTPJ-conservative/report.txt $exp_folder/appendixA/$subjectnumber-report
	# featquery group
	#featquery 1 $exp_folder/tdsocial-s05.gfeat/cope1.feat 1 stats/cope$cope_index featquery-$cope_index-$feat_dir -p -s -b $exp_folder/subj1/tdother-s5.feat/$feat_dir-sphere-mask.nii.gz

#####################beware subj1 in below code
	# featquery single
	#rm -rf ./$output_dir/featquery-$feat_dir	
	#featquery 1 $subject_dir/$output_dir 1 stats/cope1 featquery-$feat_dir -p -s -b $exp_folder/subj1/$func_dir/$feat_dir-sphere-mask.nii.gz

	# standardize mask for featquey
	#flirt -in ./$output_dir/example_func -ref $subject_dir/$func_dir/example_func -omat $subject_dir/$func_dir/tom2$td_oi.mat 
	#flirt -in ./$output_dir/featquery-$feat_dir/mask -ref $subject_dir/$func_dir/example_func -applyxfm -init $subject_dir/$func_dir/tom2$td_oi.mat -out ./$func_dir/$mask	
	#fslmaths ./$func_dir/$mask -bin ./$func_dir/$mask			
		
	# add standardized mask images together to make probablistic group mask
	#fslmaths ./$output_dir/featquery-rTPJ-conservative/mask.nii.gz -add ./$output_dir/featquery-lTPJ-conservative/mask.nii.gz -add ./$output_dir/featquery-precuneus-conservative/mask.nii.gz -bin ./$output_dir/tom_roi_mask_$subjectnumber
	
	#cluster_no=${cluster_index[part_index]}
	#thresh_no=${thresh_index[part_index]}
			
	# get clusters with GRF statistics
	#vol=$(awk 'FNR == 2 {print $2}' ./$output_dir/stats/smoothness)	
	#smooth=$(awk 'FNR == 1 {print $2}' ./$output_dir/stats/smoothness)
	#cluster --zstat=./$output_dir/stats/zstat1.nii.gz --zthresh=$z_thresh -p 0.05 -d $smooth --volume=$vol -o ./$output_dir/stats/cluster_index_$z_thresh_name --osize=./$output_dir/stats/cluster_size_$z_thresh_name > ./$output_dir/stats/cluster_info_$z_thresh_name.txt 
	
	# run individual roi analysis	
	#fslmaths -dt int ./$output_dir/stats/cluster_index_$thresh_no.nii.gz -thr $cluster_no -uthr $cluster_no -bin  ./$output_dir/stats/cluster-mask-mPFC-$thresh_no.nii.gz
	#featquery 1 $subject_dir/$func_dir 3 stats/cope2 stats/tstat2 stats/zstat2 featquery-$feat_dir -p -s -b $subject_dir/$func_dir/tom2${td_oi}-$feat_dir.nii.gz	
	
	# register masks to native space via functional image transformation
	#flirt -in ./$output_dir/filtered_func_data.nii.gz -ref ./$output_dir/reg/standard -applyxfm -init ./$output_dir/reg/example_func2standard.mat -out ./$output_dir/reg/filtered_func_standard
	#fslmaths ./tom-s5-p05.gfeat/cope1.feat/stats/precuneus_cons_standard_mask_$subjectnumber -bin ./tom-s5-p05.gfeat/cope1.feat/stats/precuneus_cons_standard_mask_$subjectnumber
	
	# PPI
        #fslmeants -i ./$output_dir/filtered_func_data -o ../tom-s5-ppi/${subjectnumber}-timecourse.txt -m ./$output_dir/featquery-rTPJ-conservative/mask

	# create sphere mask at peak coordinates and run peak roi analysis
	#mv $subject_dir/$output_dir/featquery- $subject_dir/$output_dir/featquery-rTPJ
	#peakx=0 #$(awk -v cluster_no="$cluster_no" ' { if($1==cluster_no)  print $6} ' ./$output_dir/cluster_zstat1.txt)
	#peaky=50 #$(awk -v cluster_no="$cluster_no" ' { if($1==cluster_no)  print $7} ' ./$output_dir/cluster_zstat1.txt)
	#peakz=-6 #$(awk -v cluster_no="$cluster_no" ' { if($1==cluster_no)  print $8} ' ./$output_dir/cluster_zstat1.txt)
	#fslmaths ./$output_dir/example_func.nii.gz -mul 0 -add 1 -roi $peakx 1 $peaky 1 $peakz 1 0 1 ./meta1_20mm_sphere
	#fslmaths ./$output_dir/$feat_dir-peak-sphere-mask -kernel sphere 10x10x10 -fmean ./meta1_20mm_sphere
	#featquery 1 $subject_dir/$output_dir 3 stats/cope1 stats/tstat1 stats/zstat1 featquery-sphere -p -s -b $subject_dir/$output_dir/$feat_dir-peak-sphere-mask.nii.gz
	
	# write results to array and then text file in order: all > cluster > peak
	#output_data[0]=$subjectnumber

	# featquery group
	#output_data[1]=$(cat ./tdsocial-s05.gfeat/cope1.feat/featquery-$cope_index-$feat_dir/report.txt | grep stats/cope$cope_index | awk '{print "	" $6}')	
	#echo ${output_data[@]} >> $exp_folder/td-featquery/$td_oi-s5-$feat_dir.txt
	
        # featquery single	
	#output_data[1]=$(cat ./$output_dir/featquery-$feat_dir/report.txt | grep stats/cope1 | awk '{print "	" $6}')
	#echo ${output_data[@]} >> $exp_folder/tom-featquery/tom-s8-$feat_dir.txt
done

#tr ' ' '\t' < $exp_folder/tom-featquery/tom-s8-$feat_dir.txt > $exp_folder/tom-featquery/tom-s8-new-$feat_dir.txt

