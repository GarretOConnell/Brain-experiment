# Rename files	 
exp_folder=$(pwd)	
subjlist=(19) # normies
#subjlist=(9 10 41 42 45 47) # subjects with different grefield
part_no=$(echo $((${#subjlist[*]}-1))) # subtract 1 because bash stores in [0] level
	
for part_index in $(eval echo "{0..$part_no}") ; do	
	subjectnumber=${subjlist[part_index]}
	echo $subjectnumber	
	subject_dir=$exp_folder/subj$subjectnumber/raw
	cd ${subject_dir}	
	td_files=($(ls *TDrun* -Sr | head -2 ))
	check1=($(echo ${td_files[0]} | grep -o -P 'run.{0,1}'| sed -e "s/^.*\(.\)$/\1/")) # check run number 
	check2=($(echo ${td_files[1]} | grep -o -P 'run.{0,1}'| sed -e "s/^.*\(.\)$/\1/")) 	
	if [ "$check1" == "$check2" ]; then
		cp ${td_files[0]}	 TDrun$check1.nii.gz
	echo "single"	
	else
		cp ${td_files[0]}  TDrun$check1.nii.gz	
		cp ${td_files[1]}	 TDrun$check2.nii.gz
	echo "double"		
	fi	
	td_files=($(ls TDrun*))
	run_no=$(echo $((${#td_files[*]}-1)))

	for run_index in $(eval echo "{0..$run_no}"); do	
		run=$(grep -o "[0-9]" <<<"${td_files[run_index]}") # convert linear index to filename index    

		# Flip upside brains		
		fslorient -deleteorient TDrun$run.nii.gz # Change orientation for upside down brain
		fslswapdim TDrun$run.nii.gz -x y -z swap_TDrun$run.nii.gz
		fslorient -setqformcode 1 TDrun$run.nii.gz
		fslorient -setqformcode 1 swap_TDrun$run.nii.gz
		mv TDrun$run.nii.gz  TDrun$run-original.nii.gz
		mv swap_TDrun$run.nii.gz TDrun$run.nii.gz
		# for more info see: http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Orientation#20Explained
		# make sure not to flip L/R orientation. If you do a WARNING will be triggered. 
	
		#Field Gradient Correction
		bet TDrun$run.nii.gz TDrun$run-nodif_brain -f .3 -m 
		# Brain extract tom EPI image
		
		##    else if gradient fieldmap already estimated

		#	grefield_files=($(ls ./td-grefield/*grefield*)) # first gradient file is magnitude, second is phase image
		#	cp ${grefield_files[0]} ./td-grefield/grefieldmag.nii.gz 
		#	cp ${grefield_files[1]} ./td-grefield/grefieldmap.nii.gz
			
			# Field Gradient Correction
		#	bet ./grefield-TD/grefieldmag.nii.gz ./grefield-TD/grefieldmag_brain.nii.gz -f .3 -m
			# Extract grefieldmag brain (.3 because default too tight)
		
		#	fsl_prepare_fieldmap SIEMENS ./grefield-TD/grefieldmap ./grefield-TD/grefieldmag_brain ./grefield-TD/fmap_rads 2.46
			# Create fieldmap in rads/s

		#	fslmaths ./grefield-TD/fmap_rads -mas ./grefield-TD/grefieldmag_brain_mask ./grefield-TD/fmap_rads_brain
			# Brain extraction on the grefieldmag and then apply this extraction to the real field map

		#	fugue --loadfmap=./grefield-TD/fmap_rads_brain -s 4 --savefmap=./grefield-TD/fmap_rads_brain_s4
			# Smooth the field map using –s 4

		#	fugue -v -i ./grefield-TD/grefieldmag_brain --unwarpdir=y --dwell=0.000720 --loadfmap=./grefield-TD/fmap_rads.nii.gz -w ./grefield-TD/grefieldmag_brain_warpped
			# Warp the grefieldmag image according to the deformation specified in the field map (the first fugue line)
		
		#	flirt -in ./grefield-TD/grefieldmag_brain_warpped.nii.gz -ref TDrun$run-nodif_brain.nii.gz -out ./grefield-TD/grefieldmag_brain_warpped_2_TDrun$run-nodif_brain -omat ./grefield-TD/fieldmap2TDrun$run.mat
			# Register the deformed grefieldmag image to the brain extracted b0 image

		#	flirt -in fmap_rads_brain_s4.nii.gz -ref TDrun$run-nodif_brain -applyxfm -init ./grefield-TD/fieldmap2TDrun$run.mat -out ./grefield-TD/fmap_rads_brain_s4_2_TDrun$run-nodif_brain
			# Apply this linear transformation to the field map

		#	fugue -v -i TDrun$run.nii.gz --icorr --unwarpdir=y --dwell=0.000720 --loadfmap=./grefield-TD/fmap_rads_brain_s4_2_TDrun$run-nodif_brain.nii.gz -u TDrun$run-grefield.nii.gz
			# Unwarp the full DTI dataset using the registered field map
			
		##    else if gradient fieldmap already estimated
			flirt -in grefieldmag_brain_warpped.nii.gz -ref TDrun$run-nodif_brain.nii.gz -out grefieldmag_brain_warpped_2_TDrun$run-nodif_brain -omat fieldmap2TDrun$run.mat
		#	# Register the deformed grefieldmag image to the brain extracted b0 image

			flirt -in fmap_rads_brain_s4.nii.gz -ref TDrun$run-nodif_brain -applyxfm -init fieldmap2TDrun$run.mat -out fmap_rads_brain_s4_2_TDrun$run-nodif_brain
		#	# Apply this linea	r transformation to the field map

			fugue -v -i TDrun$run.nii.gz --icorr --unwarpdir=y --dwell=0.000720 --loadfmap=fmap_rads_brain_s4_2_TDrun$run-nodif_brain.nii.gz -u TDrun$run-grefield.nii.gz
		#	# Unwarp the full DTI dataset using the registered field map

			fslmaths TDrun$run-grefield.nii.gz -mul TDrun$run-nodif_brain_mask.nii.gz TDrun$run-preproc.nii.gz
			# Whole brain mask the gradient field corrected image
	done
done


