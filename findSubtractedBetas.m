% SCRIPT INFO
% Input: SUBJID (e.g. 'sub123'), HEMISPHERE ('lh'/'rh'), LOBE (e.g. 'frontal' - output from match_lobe_voxels.m),
% ANALYSIS folder (e.g. 'sub123.self.sm0.rh.lang'), ANNOT (e.g. 'lobesfile', the name of the annotation
% file for lobe segmentation created by mri_annotation2label in
% Freesurfer), NO (e.g. 100, for analyzing 100 top beta values).
% 
% Output: Extracts a number of beta values for a specified analysis
% condition and ouput a .mat file with the beta values, and a mean beta
% value.
%
%
% Greta Tuckute, September 2018, gretatu@mit.edu

function find_subtracted_betas(SUBJID,HEMISPHERE,LOBE,ANALYSIS,ANNOT,NO)

%Manual input
SUBJID='subkg1'
HEMISPHERE='lh'
LOBE='frontal'
ANALYSIS='KG.self.sm0.lh.lang'
ANNOT='lobesfile'
NO='10'

ANALYSISDIR= ['/dir/x/x/thick/' SUBJID '/bold/' ANALYSIS];
FSDIR=['/dir/x/x/FS/' SUBJID '/label/'];

NO=str2num(NO);

% Loading betas
cd(ANALYSISDIR);
b=MRIread('beta.nii.gz');
vol=b.vol;

% Extracting betas for condition 1 (S) and condition 2 (N)
c1=vol(:,:,:,1);
c2=vol(:,:,:,2);
c=c1-c2; % Subtracting S-N

% Reading in annotations (lobes)
cd(FSDIR);
[vertices label ctab]=read_annotation([HEMISPHERE '.' ANNOT '.annot']);

% Get the lobe ID for lobe
struct_names=ctab.struct_names;

for ii=struct_names;
    tf=strcmp(ii,LOBE);
end

found=find(tf,1,'first'); % contains value of the lobe of interest
lobeID=ctab.table(found,5);

% Extracing betas for the given lobe
for elm = label;
    idx_label=[1:length(label)];
    LOBE_found=find(label == lobeID); % Finds all indices of the given lobeID
    idx_lobe=idx_label(LOBE_found); % idx_lobe contains the indices of the given lobeID
end

BETAS_lobe={}; % BETAS_lobe contains all the beta values for the specific lobe

for kk = idx_lobe;
    BETAS_lobe=[BETAS_lobe,c(kk)];
end

% Finding the top beta values
BETAS_lobe_mat=cell2mat(BETAS_lobe);
[BETAS_sorted,ix]=sort(BETAS_lobe_mat(:),'descend'); % ix is the index of the top betas for that given lobe (not overall index)
  
[rr,cc]=ind2sub(size(BETAS_lobe_mat),ix(1:NO)); % cc contains the top e.g. 10 indices for top beta values in the lobe

for ii=1:NO;
    top_BETAS(ii)=BETAS_lobe_mat(cc(ii)); % Get the top beta values, same as taking the first of BETAS_sorted
end

% Extract the index of c (the overall condition, not lobe-wise), e.g.
% c(firstval in topBETAS_overall_idx) gives the top beta value
for kk=1:NO;
    topBETAS_overall_idx(kk)=idx_lobe(cc(kk)); 
end

% Compute average beta value
BETA_mean=mean(top_BETAS);

% Saving .mat file to the analysis folder.
cd(ANALYSISDIR);
save(['betas_' num2str(NO) '_' num2str(CONDITION) '_' SUBJID '_' LOBE '.mat'],'top_BETAS','BETA_mean');

cd /dir/x/x/MATLAB_scripts/KG/
    
% Writing an info file
fileID=fopen('info_betas.txt','a'); 
fprintf(fileID,'%s\n',SUBJID,LOBE,ANALYSIS);
fprintf(fileID,'%d\n',NO,BETA_mean);

cd /dir/x/x/MATLAB_scripts/

end 