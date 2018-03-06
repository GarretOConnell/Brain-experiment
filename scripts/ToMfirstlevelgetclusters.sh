exp_folder=$(pwd)
subjlist=(1 2 3 6 8 10 12 13 14 16 18 19 21 23 24 25 26 29 30 31 32 33 34 35 36 37 38 40 41 42 43 47 48 49 50) 
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
output_dir='tom-s8.feat'
cluster_dir='ToM-cluster-p01-k50-skeleton'
k_thresh=50

for part_index in $(eval echo "{0..$part_no}"); do
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber	
	subject_dir=$exp_folder/subj$subjectnumber
	cd ${subject_dir}
	#rm -f $subject_dir/raw/masks-$cluster_dir.txt 
	awk -v cluster_dir="$cluster_dir" -v subject_dir="$subject_dir" -v k_thresh="$k_thresh" '{ if ($2 >= k_thresh && NR>=2) print subject_dir"/masks/ToM-"cluster_dir"-mask-"$1"-b0.nii.gz" }' ./$output_dir/stats/$cluster_dir/cluster_info.txt >> $subject_dir/raw/masks-$cluster_dir.txt 	
	#mask_no=$(wc -l < $subject_dir/raw/masks-$cluster_dir.txt) 
			
	#for mask_index in $(eval echo "{1..$mask_no}"); do
		#mask_path=$(sed "$mask_index"'q;d' $subject_dir/raw/masks-$cluster_dir.txt)
		#mask_target=$(echo $mask_path | sed -e "s/.*mask-//;s/-b0*//")
		#fslmaths ./raw/ToM-$cluster_dir -bin ./masks/ToM-$cluster_dir-b0.nii.gz					
		#fslmaths ./masks/tbss_skeleton_mask -mul ./masks/ToM-$cluster_dir-b0.nii.gz ./masks/ToM-$cluster_dir-skeleton.nii.gz
		#fslmaths -dt int cluster_index -thr 7 -uthr 7 -bin cluster_mask7
		fslmeants -i $subject_dir/raw/dtifit_FA.nii.gz -o $subject_dir/raw/$cluster_dir.txt -m $subject_dir/masks/$cluster_dir.nii.gz
		output_data[0]=$subjectnumber
		output_data[1]=$(cat $subject_dir/raw/$cluster_dir.txt | awk '{print $1}')

		echo ${output_data[@]} >> $exp_folder/tbss/roi/$cluster_dir.txt
	#fslmaths -dt int ./$output_dir/stats/$cluster_dir/cluster_index -thr $mask_target -uthr $mask_target -bin  ./masks/ToM-$cluster_dir-mask-$mask_target.nii.gz
	#done	
done
tr ' ' '\t' < $exp_folder/tbss/roi/$cluster_dir.txt > $exp_folder/tbss/roi/$cluster_dir-new.txt
