% SCRIPT INFO
% Input: SUBJID (e.g. 'sub123'), HEMISPHERE ('lh'/'rh'), LOBE (e.g. 'frontal' - output from match_lobe_voxels.m),
% ANALYSIS folder (e.g. 'sub123.self.sm0.rh.lang'), CONTRAST (e.g. 'SvsN'), THRESHOLD (e.g. 0.01).
% 
% Output: saves .mat file with 'SUBJID','VOXELCOUNT','VALUECOUNT', 'PVALUES', 'MEANPVALUE'
% Output dir: /mri-space2/thick/stats/
% Output format: SUBJID_threshold_ANALYSIS.mat, e.g. sub123_t3_sub123.self.sm0.lh.lang.mat
%
% Courtesy to David Beeler for providing a script to build upon.
%
% Greta Tuckute, August 2018, gretatu@mit.edu


function takeThreshold(SUBJID,HEMISPHERE,LOBE,ANALYSIS,CONTRAST,THRESHOLD)
    PTHRESHOLD=str2num(THRESHOLD);

    MEANFUNCDIR=['/dir/x/x/' SUBJID '/bold/' ANALYSIS];
    SIGMAP=MRIread([MEANFUNCDIR '/' CONTRAST '/extracted_lobe_voxels/' SUBJID '_' HEMISPHERE '_' LOBE '.nii.gz']);
    ROI=SIGMAP; %struct, find values in FRONTAL_sig
    unique(ROI.vol);
   
    TOTALVOXELS=length(SIGMAP.vol(:)); %total num of voxels within that lobe
   
    SIGMAP.vol(SIGMAP.vol==0)=0;
    LOGTHRESH=-log10(PTHRESHOLD);
    SIZE=size(ROI.vol);
    VOXELCOUNT=0;
    VALUECOUNT=0;
    PVALUES=[];
    for x=1:SIZE(1);
        for y=1:SIZE(2);
                if SIGMAP.vol(x,y)>LOGTHRESH;
                    disp(x);
                    VOXELCOUNT=VOXELCOUNT+1;
                    VALUECOUNT=VALUECOUNT+SIGMAP.vol(x,y);
                    PVALUES(length(PVALUES)+1)=SIGMAP.vol(x,y);
                    ROI.vol(x,y)=1;
                end
        end
    end
                  
    MEANPVALUE=mean(PVALUES);
    
    % Converting MEANPVALUE (in -log10) to normal p-value (0-1)
    PRINTMEANPVAL=10^(-MEANPVALUE);
    PRINTPVALUES=10.^(-PVALUES);
    
    save(['/save/dir/stats/' SUBJID '_' LOBE '_t' num2str(-log10(str2num(THRESHOLD))) '_' ANALYSIS '.mat'],'SUBJID','VOXELCOUNT','VALUECOUNT', 'PVALUES', 'PRINTPVALUES','MEANPVALUE','PRINTMEANPVAL');
    
    % Writing an info file
    fileID=fopen('info_takeThreshold_KG.txt','a'); 
    fprintf(fileID,'%s\n',SUBJID,LOBE,ANALYSIS,THRESHOLD);
    fprintf(fileID,'%d\n',VOXELCOUNT,MEANPVALUE,PRINTMEANPVAL);
    
    cd /dir/x/x/

end