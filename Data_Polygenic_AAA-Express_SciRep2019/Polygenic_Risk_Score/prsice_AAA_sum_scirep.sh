#!/bin/bash
#
#$ -S /bin/bash 																				# the type of BASH you'd like to use
#$ -N PRSAAA_sum  																			# the name of this script
# -hold_jid some_other_basic_bash_script  														# the current script (basic_bash_script) will hold until some_other_basic_bash_script has finished
#$ -o /hpc/dhl_ec/cvanlaarhoven/genetics/aneurysmexpress/Polygen/PRSICE/PRSAAA_sum.v3.log  	# the log file of this job
#$ -e /hpc/dhl_ec/cvanlaarhoven/genetics/aneurysmexpress/Polygen/PRSICE/PRSAAA_sum.v3.errors 	# the error file of this job
#$ -l h_rt=03:00:00  																			# h_rt=[max time, e.g. 02:02:01] - this is the time you think the script will take
#$ -l h_vmem=120G  																				#  h_vmem=[max. mem, e.g. 45G] - this is the amount of memory you think your script will use
# -l tmpspace=64G  																				# this is the amount of temporary space you think your script will use
#$ -M s.w.vanderlaan-2@umcutrecht.nl  															# you can send yourself emails when the job is done; "-M" and "-m" go hand in hand
#$ -m beas  																						# you can choose: b=begin of job; e=end of job; a=abort of job; s=suspended job; n=no mail is send
#$ -cwd  																						# set the job start to the current directory - so all the things in this script are relative to the current directory!!!
#
### INTERACTIVE SHELLS
# You can also schedule an interactive shell, e.g.:
#
# qlogin -N "basic_bash_script" -l h_rt=02:00:00 -l h_vmem=24G -M s.w.vanderlaan-2@umcutrecht.nl -m ea
#
# You can use the variables above (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

##########################################################################################
### Created by		Sander W. van der Laan | UMC Utrecht | s.w.vanderlaan[at]gmail[dot]com
###					Constance J.H.C.M. van Laarhoven | UMC Utrecht | c.j.h.vanlaarhoven@umcutrecht.nl
### Last edit		2019-11-12
### Version			1.2.2
##########################################################################################

### Creating display functions
### Setting colouring
NONE='\033[00m'
BOLD='\033[1m'
OPAQUE='\033[2m'
FLASHING='\033[5m'
UNDERLINE='\033[4m'

RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
### Regarding changing the 'type' of the things printed with 'echo'
### Refer to: 
### - http://askubuntu.com/questions/528928/how-to-do-underline-bold-italic-strikethrough-color-background-and-size-i
### - http://misc.flogisoft.com/bash/tip_colors_and_formatting
### - http://unix.stackexchange.com/questions/37260/change-font-in-echo-command

### echo -e "\033[1mbold\033[0m"
### echo -e "\033[3mitalic\033[0m" ### THIS DOESN'T WORK ON MAC!
### echo -e "\033[4munderline\033[0m"
### echo -e "\033[9mstrikethrough\033[0m"
### echo -e "\033[31mHello World\033[0m"
### echo -e "\x1B[31mHello World\033[0m"

function echocyan { #'echobold' is the function name
    echo -e "${CYAN}${1}${NONE}" # this is whatever the function needs to execute.
}
function echobold { #'echobold' is the function name
    echo -e "${BOLD}${1}${NONE}" # this is whatever the function needs to execute, note ${1} is the text for echo
}
function echoitalic { #'echobold' is the function name
    echo -e "\033[3m${1}\033[0m" # this is whatever the function needs to execute.
}

script_copyright_message() {
	echo ""
	THISYEAR=$(date +'%Y')
	echoitalic "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echoitalic "+ The MIT License (MIT)                                                                                 +"
	echoitalic "+ Copyright (c) 1979-${THISYEAR} Sander W. van der Laan                                                        +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and     +"
	echoitalic "+ associated documentation files (the \"Software\"), to deal in the Software without restriction,         +"
	echoitalic "+ including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, +"
	echoitalic "+ and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, +"
	echoitalic "+ subject to the following conditions:                                                                  +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ The above copyright notice and this permission notice shall be included in all copies or substantial  +"
	echoitalic "+ portions of the Software.                                                                             +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT     +"
	echoitalic "+ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                +"
	echoitalic "+ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  +"
	echoitalic "+ OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   +"
	echoitalic "+ CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                            +"
	echoitalic "+                                                                                                       +"
	echoitalic "+ Reference: http://opensource.org.                                                                     +"
	echoitalic "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}


echocyan "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echocyan "                           POLYGENIC SCORE CALCULATIONS"
echocyan ""
echocyan ""
echocyan "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echobold "*Setting the environment."

SOFTWARE="/hpc/local/CentOS7/dhl_ec/software/"
HERCULESTOOLKIT="${SOFTWARE}/HerculesToolKit"

### Project specific
PROJECTDIR="/hpc/dhl_ec/cvanlaarhoven/genetics/aneurysmexpress/Data_Polygenic_AAA-Express_SciRep2019/Polygenic_Risk_Score"
ORIGINALDATA="/hpc/dhl_ec/cvanlaarhoven/genetics/aneurysmexpress/Data_Polygenic_AAA-Express_SciRep2019/Individual_SNP_lookup"

echobold "* Making some directories."
### Make directories for script if they do not exist yet (!!!PREREQUISITE!!!)
if [ ! -d ${PROJECTDIR}/PRSICE/ ]; then
	echo "The PRSICE directory does not exist, Mr. Bourne will make it for you!"
	mkdir -v ${PROJECTDIR}/PRSICE/
fi
PRSICEDIR=${PROJECTDIR}/PRSICE

# chmod -R a+rwx ${PROJECTDIR}

echobold "* Setting some variables specific for PRSice calculations."
echoitalic " > data files ..."

### Fill in BASE and TARGET data-files
### Note: make sure you have the same variantID-nomenclature in both files...
### Add " --type bgen " if you want to use dosage data, instead of hardcoded genotypes
### HEADER
### VariantID RSID CHR BP AlleleA AlleleB BETA SE P
### 1:776546 rs12124819 01 776546 A G 1 1 0.5256
### 1:798400 rs10900604 01 798400 A G -1 1 0.1198
### 1:798959 rs11240777 01 798959 A G 1 1 0.1424
BASEDATA="/hpc/dhl_ec/svanderlaan/projects/aaags/gwas_data/AAA_MetaGWAS_Metal.2017.CircRes2017.edit.4PRSice.aaags_matched.txt"

TARGETDATA="/hpc/dhl_ec/data/_aaa_originals/AAAGS_IMPUTE2_1000Gp3_GoNL5/aaags_1kGp3GoNL5_RAW_chr#"

### Making the phenotype-file is project specific
echoitalic " > getting a phenotype file and exclusion list."

### DEBUGGING
# echo ""
# echo "   - heads ..."
# head ${ORIGINALDATA}/aaags.phenocov.sample 

echo ""
echo "   - creating new pheno-file ..."
# echo "FID IID Hospital HospitalCoded PlateNr SampleType STUDY_TYPE sex Age AgeSQR Smoker OR_year OR_year_C PC1 PC2 PC3 PC4 PC5 PC6 PC7 PC8 PC9 PC10 Cov_Artery Ageatsurgery AneurysmDiameter SympBino Ruptured TypeBino" > ${PROJECTDIR}/aaags_phenocov.pheno
# cat ${ORIGINALDATA}/pheno_cov_exclusions/aaags_phenocov.sample_biom_NoOutliers | \
# parseTable --col ID_2,ID_1,Hospital,HospitalCoded,PlateNr,SampleType,STUDY_TYPE,sex,Age,AgeSQR,Smoker,OR_year,OR_year_C,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,Cov_Artery,Ageatsurgery,AneurysmDiameter,SympBino,Ruptured,TypeBino | \
# tail -n +3 | \
# sed 's/FEMALE/2/g' | sed 's/MALE/1/g' >> ${PROJECTDIR}/aaags_phenocov.pheno

### DEBUGGING
# echo ""
# echo "   - heads ..."
# head  ${PROJECTDIR}/aaags_phenocov.pheno
# echo ""
# echo "   - tails ..."
# tail  ${PROJECTDIR}/aaags_phenocov.pheno
# echo ""
# echo "   - counts ..."
# cat  ${PROJECTDIR}/aaags_phenocov.pheno | tail -n +2 | wc -l

### Be sure to make the proper exclusion list and make sure it has the headers FID IID!

### 
echoitalic " > PRSice general and plotting settings ..."
### Specific PRSice settings
### --no-clump:  don't use clump if you already filtered the data; in case of most GWAS results
###              you do want to use clumping
### --print-snp: print a list of SNPs used in the end in the modeling
### --all-score: you want to print out all the calculated scores for each p-value threshold,
###              handy if you want to do some offline modeling down the road
### --extract:   the first time you run PRSice it will stop and state "you should --extract"
###              to include only the valid variants. You can re-run doing just that...

# PRSICESETTINGS="--no-clump --print-snp --extract PRSice.valid --score sum --missing center --all-score --perm 10000"
# PRSICESETTINGS="--print-snp --extract PRSice.valid --score std --all-score --clump-kb 500 --clump-r2 0.05 --pearson --ld-maf 0.05 --proxy 0.8 "
# PRSICESETTINGS="--print-snp --extract PRSice.valid --score average --all-score --clump-kb 500 --clump-r2 0.05 --pearson --ld-maf 0.05 --proxy 0.8 "

PRSICESETTINGS="--print-snp --extract PRSice.valid --score sum --all-score --clump-kb 500 --clump-r2 0.1 --pearson --ld-maf 0.05 --ld-info 0.9 --proxy 0.8 "

# PRSICEPLOTTING="--fastscore --bar-col-high #E55738 --bar-col-low #1290D9 --quantile 100 --quant-break 2.5,5,10,20,40,60,80,90,95,97.5,100 --quant-ref 60"
# PRSICEPLOTTING="--fastscore --bar-col-high #E55738 --bar-col-low #1290D9 --quantile 10"

PRSICEPLOTTING="--fastscore --bar-col-high #E55738 --bar-col-low #1290D9 --quantile 100 --quant-break 2.5,5,10,20,40,60,80,90,95,97.5,100 --quant-ref 60 --no-full"

PRSICETHREADS="2"
PRSICESEED="91149214" # just a random number

# PRSICEBARLEVELS="0.00000005,0.0000005,0.000005,0.00005,0.0005,0.005,0.05,0.1,0.2,0.3,0.4,0.5,1"
# PRSICEBARLEVELS="0.00000005,0.000005,0.0005,0.001,0.01,0.05,0.1,0.2,0.5,1"
PRSICEBARLEVELS="0.00000005,0.000005,0.0005,0.001,0.01,0.05,0.1,0.2,0.5"
# PRSICEBARLEVELS="0.00000005,0.000005,0.0005,0.001,0.01,0.05,0.1,0.2,0.5 --plot "
echo ""
echo "barlevels: ${PRSICEBARLEVELS}"

SCORETYPE="PRSsum_LD500_r2_0_1_info_0_9_FastScore" # you can use different scoring algorithms, 'sum' (sum of effect sizes), 'std' (standardized effect size), or 'average' (average effect size).
DATATYPE="BED" # you can use the Oxford-style BGEN format or the PLINK-style BED format
PERMUTATION="NOPERM_NOCENTER" # be explicit in the output-file name: did you use permutation, center?

echoitalic " > PRSice statistics settings ..."
STATTYPE="--beta" 

### Make sure these are the exact column-names in your BASEDATA
SNPID="RSID"
CHRID="CHR"
BPID="BP"
A1ID="AlleleA"
A2ID="AlleleB"
STATID="BETA"
PVALUEID="P"

echoitalic " > Phenotypes and covariates ..."

PHENOTYPEFILE="${PROJECTDIR}/aaags_phenocov.pheno"
COVARIATES_DIAM="sex,Age,@PC[1-4],Smoker,Cov_Artery"
COVARIATES_SMOKER="sex,Age,@PC[1-4],AneurysmDiameter,Smoker"

COVARIATESFACTOR_SMOKER="sex,Smoker"
COVARIATESFACTOR_DIAM="sex,Smoker,Cov_Artery"

COVARIATESFILE="${PROJECTDIR}/aaags_phenocov.pheno"
EXCLUSION="${PROJECTDIR}/exclusion_nonAAAGS_ID_scirep.list"

#### Example binary trait
echoitalic " > Binary traits ..."
# for PHENO in SympBino Ruptured TypeBino ; do 
for PHENO in TypeBino ; do 
	
	echo ""
	echoitalic "   - setting phenotype [ ${PHENO} ] ..."
	TARGETTYPE="T"
	PHENOTYPE="${PHENO}"
	PRSICEOUTPUTNAME="--out PRSice.${PHENOTYPE}.${SCORETYPE}.${DATATYPE}.${PERMUTATION}"
	
	echo ""
	echoitalic "   - moving to proper directory [ ${PRSICEDIR} ] ..."
	cd ${PRSICEDIR}
	
	echo ""
	echoitalic "   - starting PRSice ..."
	PRSice_v214.R --prsice $(command -v prsice_v214) \
	--dir ${PRSICEDIR} \
	--seed ${PRSICESEED} \
	--bar-levels ${PRSICEBARLEVELS} \
	--base ${BASEDATA} \
	--target ${TARGETDATA} \
	--thread ${PRSICETHREADS} \
	${STATTYPE} \
	--binary-target ${TARGETTYPE} \
	--snp ${SNPID} \
	--chr ${CHRID} \
	--bp ${BPID} \
	--A1 ${A1ID} \
	--A2 ${A2ID} \
	--stat ${STATID} \
	--pvalue ${PVALUEID} \
	--cov-file ${COVARIATESFILE} \
	--cov-col ${COVARIATES_SMOKER} \
	--cov-factor ${COVARIATESFACTOR_SMOKER} \
	--pheno-file ${PHENOTYPEFILE} \
	--pheno-col ${PHENOTYPE} \
	--remove ${EXCLUSION} \
	${PRSICEPLOTTING} \
	${PRSICESETTINGS} \
	${PRSICEOUTPUTNAME}

done

#### Example quantitative trait
# echoitalic " > Quantitative traits ..."
for PHENO in AneurysmDiameter ; do 
	
	echo ""
	echoitalic "   - setting phenotype [ ${PHENO} ] ..."
	TARGETTYPE="F"
	PHENOTYPE="${PHENO}"
	PRSICEOUTPUTNAME="--out PRSice.${PHENOTYPE}.${SCORETYPE}.${DATATYPE}.${PERMUTATION}"
	
	echo ""
	echoitalic "   - moving to proper directory [ ${PRSICEDIR} ] ..."
	cd ${PRSICEDIR}
	
	echo ""
	echoitalic "   - starting PRSice ..."
	PRSice_v214.R --prsice $(command -v prsice_v214) \
	--dir ${PRSICEDIR} \
	--seed ${PRSICESEED} \
	--bar-levels ${PRSICEBARLEVELS} \
	--base ${BASEDATA} \
	--target ${TARGETDATA} \
	--thread ${PRSICETHREADS} \
	${STATTYPE} \
	--binary-target ${TARGETTYPE} \
	--snp ${SNPID} \
	--chr ${CHRID} \
	--bp ${BPID} \
	--A1 ${A1ID} \
	--A2 ${A2ID} \
	--stat ${STATID} \
	--pvalue ${PVALUEID} \
	--cov-file ${COVARIATESFILE} \
	--cov-col ${COVARIATES_DIAM} \
	--cov-factor ${COVARIATESFACTOR_DIAM} \
	--pheno-file ${PHENOTYPEFILE} \
	--pheno-col ${PHENOTYPE} \
	--remove ${EXCLUSION} \
	${PRSICEPLOTTING} \
	${PRSICESETTINGS} \
	${PRSICEOUTPUTNAME}

done

script_copyright_message


