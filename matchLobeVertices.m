% SCRIPT INFO
% Input: SUBJID (e.g. 'sub123'), HEMISPHERE ('lh'/'rh'), LOBE (e.g. 'frontal' - output from match_lobe_voxels.m),
% ANALYSIS folder (e.g. 'sub123.self.sm0.rh.lang'), CONTRAST (e.g. 'SvsN'), ANNOT (e.g. 'lobesfile', the name of the annotation
% file for lobe segmentation created by mri_annotation2label in Freesurfer).
%
% Output: 
% Outputs a .mat file with the t-values of the vertices within the input lobe or a .nii.gz vol-file with the same vertices.
% Extracts significance values for the vertices for the input lobe by using the sig.nii.gz file (t-values). 
% Takes an .annot file for the lobe segmentation from FS/SUBJID/label/
% Output dir: /SUBJID/bold/ANALYSIS/CONTRAST/extracted_lobe_voxels/
% (output dir created when running the script)
%
%
% Greta Tuckute, August 2018, gretatu@mit.edu

function match_lobe_voxels_func(SUBJID,HEMISPHERE,LOBE,ANALYSIS,CONTRAST,ANNOT)

%     SUBJID='subkg1'
%     ANALYSIS='sub123.self.sm0.lh.lang'
%     CONTRAST='SvsN'
%     HEMISPHERE='lh'
%     LOBE='frontal'
%     ANNOT='lobesfile'
    FSDIR=['/dir/x/x/thick/FS/' SUBJID '/label/'];
    CONTRASTDIR= ['/dir/x/x/thick/' SUBJID '/bold/' ANALYSIS '/' CONTRAST];

    % Reading in annotations.

    cd(FSDIR);

    [vertices label ctab]=read_annotation([HEMISPHERE '.' ANNOT '.annot']);

    % Get the lobe ID for (frontal) lobe

    struct_names=ctab.struct_names;

    for ii=struct_names;
        tf=strcmp(ii,LOBE);
    end

    found=find(tf,1,'first'); %contains value of the lobe of interest

    lobeID=ctab.table(found,5);

    % Reading in sig.nii.gz for lang.lh

    cd(CONTRASTDIR);

    CONTRASTsig=MRIread('sig.nii.gz');

    % Finding out which unique labels I have 
    UNIQUElabels=unique(label);

    VOLvals=CONTRASTsig.vol;

    % I want to extract the volume values corresponding to the labels in label
    % trying to transpose, to get the structure same as label/vertices

    VOLvalsT=VOLvals';
    
    for elm = label;

        idx_label=[1:length(label)];
        FRONTAL=find(label == lobeID); %finds all indices of 6500 in label (frontal)
        idx_frontal=idx_label(FRONTAL); %this index list contains the indices of value 6500

    end

    FRONTAL_sig={}; % Has all the significance values for frontal lobe = label 6500

    for kk = idx_frontal;
        FRONTAL_sig=[FRONTAL_sig,VOLvalsT(kk)];
    end

    % Saving .mat and .nii.gz files to a subfolder inside the
    % ANALYSIS/CONTRAST/ folder

    unix(['mkdir ' CONTRASTDIR '/extracted_lobe_voxels/']);

    EXTRACTDIR=['/dir/x/x/thick/' SUBJID '/bold/' ANALYSIS '/' CONTRAST '/extracted_lobe_voxels/']

    cd(EXTRACTDIR)

    % Saving .mat file to the contrast folder inside EXTRACTDIR.

    save([SUBJID '_' HEMISPHERE '_' LOBE '.mat'],'FRONTAL_sig');

    % Saving .nii.gz file to the contrast folder inside EXTRACTDIR

    FRONTAL_sig_mat=cell2mat(FRONTAL_sig);

    s=CONTRASTsig;

    s.vol=FRONTAL_sig_mat; 

    MRIwrite(s,[SUBJID '_' HEMISPHERE '_' LOBE '.nii.gz'])
    
    cd /save/dir/
    
    % Writing an info file
    fileID=fopen('info_match_KG.txt','a'); 
    fprintf(fileID,'%s\n',SUBJID,LOBE,ANALYSIS);
    fprintf(fileID,'%d\n',found,lobeID,length(FRONTAL));
    % no_extracted_voxels=length(FRONTAL);
  
    %save('info_match_lobe_voxels.mat','found','lobeID','no_extracted_voxels','-append','-ascii')
    
    cd /dir/x/x/MATLAB_scripts/


end 