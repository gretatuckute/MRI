% SCRIPT INFO
% Computes projection distance(projdist)/gray matter intensity files (for
% cortical thickness analysis).
% Input: subject ID, hemisphere, analysis folder name (in bold directory),
% contrast, annotation file name (e.g. if lh.lobesfile.annot, input is
% 'lobesfile').
% 
% Output: saves .mat and .nii.gz file with 'FRONTAL_projdist','TEMPORAL_projdist','PARIETAL_projdist'
% Output dir: ../dir/x/x/thick/projdist_files/
% 
% Output: saves .txt file with info for all subjects in
% /MATLAB_scripts/projdist/
% Saves info about SUBJID, ANALYSIS, CONTRAST, no. of vertices above threshold 3, mean value of the projdist
% intensity for frontal, temporal and parietal lobes
%
% Greta Tuckute, August 2018, gretatu@mit.edu

function projdist(SUBJID,HEMISPHERE,ANALYSIS,CONTRAST,ANNOT)

FSDIR=['/dir/x/x/FS/' SUBJID '/label/'];
CONTRASTDIR= ['/dir/x/x/thick/' SUBJID '/bold/' ANALYSIS '/' CONTRAST];

% Reading in annotations.

cd(FSDIR);

[vertices l ctab]=read_annotation([HEMISPHERE '.' ANNOT '.annot']);

l=l';

% Get the lobe IDs for 3 lobes

struct_names=ctab.struct_names;

% FRONTAL LOBE
for ii=struct_names;
    tf_frontal=strcmp(ii,'frontal');
end

found_frontal=find(tf_frontal,1,'first'); %contains value of the lobe of interest
lobeID_frontal=ctab.table(found_frontal,5);

% TEMPORAL LOBE
for jj=struct_names;
    tf_temporal=strcmp(jj,'temporal');
end

found_temporal=find(tf_temporal,1,'first'); %contains value of the lobe of interest
lobeID_temporal=ctab.table(found_temporal,5);

% PARIETAL LOBE
for gg=struct_names;
    tf_parietal=strcmp(gg,'parietal');
end

found_parietal=find(tf_parietal,1,'first'); %contains value of the lobe of interest
lobeID_parietal=ctab.table(found_parietal,5);

% Loading in sig.nii.gz for ANALYSIS/CONTRAST/

cd(CONTRASTDIR);

sig=MRIread('sig.nii.gz');
s=sig.vol;

% Loading in projdist.mgh file 

% Name projdist file subXXX_HEMISPHERE_projdist.mgh. Put in the same folder

cd /dir/x/x/projdist_files/input/

proj=MRIread([SUBJID '_' HEMISPHERE '_projdist.mgh']);

p=proj.vol; % Contains the norm intensity for all vertices

% uniquep=unique(p);

% 6500 = frontal
% 14474380 = temporal
% 1351760 = parietal 

% l for label, s for sig and p for projdist 

% For FRONTAL
for elm = l;
    idx_label_f=[1:length(l)];
    FRONTAL=find(l == 6500); %finds all indices of 6500 in label (frontal)
    idx_frontal=idx_label_f(FRONTAL); %this index list contains the indices of value 6500
end

% For TEMPORAL
for ele = l;
    idx_label_t=[1:length(l)];
    TEMPORAL=find(l == 14474380); 
    idx_temporal=idx_label_t(TEMPORAL); 
end

% For PARIETAL
for elem = l;
    idx_label_p=[1:length(l)];
    PARIETAL=find(l == 1351760); 
    idx_parietal=idx_label_p(PARIETAL); 
end

FRONTAL_projdist={}; % Has all the projdist values for frontal lobe = label 6500 if sig > 3
TEMPORAL_projdist={};
PARIETAL_projdist={};

for kk = idx_frontal;
    if s(kk)>3 %if sig >3
        FRONTAL_projdist=[FRONTAL_projdist,p(kk)]; % take lobe index of projdist
    end
end

for nn = idx_temporal;
    if s(nn)>3 %if sig >3
        TEMPORAL_projdist=[TEMPORAL_projdist,p(nn)]; % take lobe index of projdist
    end
end

for mm = idx_parietal;
    if s(mm)>3 %if sig >3
        PARIETAL_projdist=[PARIETAL_projdist,p(mm)]; % take lobe index of projdist
    end
end

% Computing mean of projdist for FRONTAL, TEMPORAL and PARIETAL

FRONTAL_proj_mat=cell2mat(FRONTAL_projdist);
TEMPORAL_proj_mat=cell2mat(TEMPORAL_projdist);
PARIETAL_proj_mat=cell2mat(PARIETAL_projdist);

mean_FRONTAL=mean(FRONTAL_proj_mat);
mean_TEMPORAL=mean(TEMPORAL_proj_mat);
mean_PARIETAL=mean(PARIETAL_proj_mat);

% Saving .mat and .nii.gz files inside /thick/ directory. 

SAVEDIR=['/dir/x/x/projdist_files/output/']

cd(SAVEDIR)

% Saving .mat file

save([SUBJID '_' ANALYSIS '_' CONTRAST '.mat'],'FRONTAL_projdist','TEMPORAL_projdist','PARIETAL_projdist');

% Saving .nii.gz file (separately for each lobe)

t=sig;
t.vol=FRONTAL_proj_mat; 
MRIwrite(t,[SUBJID '_FRONTAL_' ANALYSIS '_' CONTRAST '.nii.gz']);

u=sig;
u.vol=TEMPORAL_proj_mat; 
MRIwrite(u,[SUBJID '_TEMPORAL_' ANALYSIS '_' CONTRAST '.nii.gz']);

r=sig;
r.vol=PARIETAL_proj_mat; 
MRIwrite(r,[SUBJID '_PARIETAL_' ANALYSIS '_' CONTRAST '.nii.gz']);


cd /dir/x/x/MATLAB_scripts/projdist/

% ADD LENGTH OF projdist, to see how many vertices were a part of this 

% Writing an info file
fileID=fopen('info_projdist.txt','a'); 
fprintf(fileID,'%s\n',SUBJID,ANALYSIS,CONTRAST);
fprintf(fileID,'%d\n',length(FRONTAL_proj_mat),mean_FRONTAL,length(TEMPORAL_proj_mat),mean_TEMPORAL,length(PARIETAL_proj_mat),mean_PARIETAL);
cd /dir/x/x/MATLAB_scripts/


