# Rename files	 
exp_folder=$(pwd)
subjlist=(49)
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
	
for part_index in $(eval echo "{0..$part_no}")  
	do
	subjectnumber=${subjlist[part_index]}
	subject_dir=$exp_folder/subj$subjectnumber
	cd ${subject_dir}

	tom_files=$(ls ./raw/*tomloc* --sort=size | head -1 )	
	cp ${tom_files} ./raw/tomloc.nii.gz 

	# Change orientation for upside down brain
	#fslorient -deleteorient ./raw/tomloc.nii.gz
	#fslswapdim ./raw/tomloc -x y -z ./raw/swap_tomloc.nii.gz
	#fslorient -setqformcode 1 ./raw/tomloc.nii.gz
	#fslorient -setqformcode 1 ./raw/swap_tomloc.nii.gz
	#mv ./raw/tomloc.nii.gz  ./raw/tomloc_original.nii.gz
	#mv ./raw/swap_tomloc.nii.gz ./raw/tomloc.nii.gz
	# for more info see: http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Orientation#20Explained
	# make sure not to flip L/R orientation. IF you do a WARNING will be triggered. 
	
	#Field Gradient Correction
	bet ./raw/tomloc.nii.gz ./raw/tom_nodif_brain -f .3 -m 
	# Brain extract tom EPI image

	flirt -in ./raw/grefieldmag_brain_warpped.nii.gz -ref ./raw/tom_nodif_brain.nii.gz -out ./raw/grefieldmag_brain_warpped_2_tom_nodif_brain -omat ./raw/fieldmap2tom.mat
	# Register the deformed grefieldmag image to the brain extracted b0 image

	flirt -in ./raw/fmap_rads_brain_s4.nii.gz -ref ./raw/tom_nodif_brain -applyxfm -init ./raw/fieldmap2tom.mat -out ./raw/fmap_rads_brain_s4_2_tom_nodif_brain
	# Apply this linear transformation to the field map

	fugue -v -i ./raw/tomloc.nii.gz --icorr --unwarpdir=y --dwell=0.000720 --loadfmap=./raw/fmap_rads_brain_s4_2_tom_nodif_brain.nii.gz -u ./raw/tom.nii.gz
	# Unwarp the data using the registered field map

	fslmaths ./raw/tom.nii.gz -mul ./raw/tom_nodif_brain_mask.nii.gz ./raw/tom_grefield.nii.gz
	# Whole brain mask the gradient field corrected image
done


