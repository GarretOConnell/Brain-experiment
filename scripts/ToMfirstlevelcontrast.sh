exp_folder=$(pwd)
subjlist=(11) #1 2 3 6 8 9 10 12 13 14 16 17 18 19 20 21 22 23 24 25 26 29 30 31 32 33 34 35 36 37 38 40 41 42 43 44 45 46 47 48 49 50) 
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
output_dir='tom-s8.feat'
z_thresh=2.3 # z=1.6 is p<.05, z=2.3 is p<.01, z=3.1
p_thresh=01
k_thresh=50
cluster_dir='cluster-p01-k50'
for part_index in $(eval echo "{0..$part_no}"); do
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber	
	subject_dir=$exp_folder/subj$subjectnumber
	cd ${subject_dir}
	mkdir ./$output_dir/stats/$cluster_dir	
	cluster -i ./$output_dir/stats/zstat1 -t $z_thresh -o ./$output_dir/stats/$cluster_dir/cluster_index --osize=./$output_dir/stats/$cluster_dir/cluster_size > ./$output_dir/stats/$cluster_dir/cluster_info.txt		
	
	# Extract overall cluster mask	
	fslmaths ./$output_dir/stats/$cluster_dir/cluster_size.nii.gz -thr $k_thresh ./$output_dir/stats/$cluster_dir/cluster_k_thresh.nii.gz	
	fslmaths ./$output_dir/stats/$cluster_dir/cluster_k_thresh.nii.gz -bin ./$output_dir/stats/$cluster_dir/cluster_k_thresh_mask.nii.gz 	
done
