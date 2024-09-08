function preprocessing_fmri_BTAPE(task)
% Initialize SPM
spm('defaults', 'FMRI');
spm_jobman('initcfg');
% Add SPM directory
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM working directory:
addpath(spmdir)
specdir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BTAPE_jobs';
addpath(specdir)
% Define the base directory where the subfolders are located
base_dir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BIDS\sub-01\func';
addpath(base_dir)

% Specify the subfolder names where .nii files are located
subfolders = {'sub-01_task-BTP_run-5_bold', 'sub-01_task-BTP_run-8_bold', ...
              'sub-01_task-BTP_run-11_bold', 'sub-01_task-BTP_run-14_bold', ...
              'sub-01_task-BTP_run-17_bold', 'sub-01_task-BTP_run-19_bold', ...
              };
func_files = {'MFBTAPE-0005-%05d-%06d.nii,1', 'MFBTAPE-0008-%05d-%06d.nii,1', ...    % .nii functional files
              'MFBTAPE-0011-%05d-%06d.nii,1', 'MFBTAPE-0014-%05d-%06d.nii,1', ...
              'MFBTAPE-0017-%05d-%06d.nii,1', 'MFBTAPE-0019-%05d-%06d.nii,1'};      
re_func_files =  {'rMFBTAPE-0005-%05d-%06d.nii,1', 'rMFBTAPE-0008-%05d-%06d.nii,1', ...  %realigned functinal files for normalisation
                 'rMFBTAPE-0011-%05d-%06d.nii,1', 'rMFBTAPE-0014-%05d-%06d.nii,1', ...
                 'rMFBTAPE-0017-%05d-%06d.nii,1', 'rMFBTAPE-0019-%05d-%06d.nii,1'};
norm_func_files = {'wrMFBTAPE-0005-%05d-%06d.nii,1', 'wrMFBTAPE-0008-%05d-%06d.nii,1', ...    %spatially normalised files for smoothing      
                   'wrMFBTAPE-0011-%05d-%06d.nii,1', 'wrMFBTAPE-0014-%05d-%06d.nii,1', ...
                    'wrMFBTAPE-0017-%05d-%06d.nii,1', 'wrMFBTAPE-0019-%05d-%06d.nii,1'};
                                                                                    
anatdir= 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BIDS\sub-01\anat\sub-01_T1w';
addpath(anatdir)
%This functionis a batch script for pre-processing fMRI data
    % INPUT ARGUMENTS:
    %%%%% 'task'
    % if task not given, then it defaults to '123456'
    %           
    %           1 = REALIGNMENT
    %           2 = COREGISTRATION 
    %           3 = SEGMENTATION
    %           4 = NORMALISATION (functional)
    %           5 = NORMALISATION_PART2 (Structural)
    %           6 = SMOOTHING
    if ~exist('task','var') 
        task='123456'; 
    end % if nothing is specified in "task" ,this is the default action
    %% 
    % Initialize job structure for current subfolder
     job = [];
 for j = 1:numel(subfolders)
        % Construct full path to the current subfolder
        current_subfolder = fullfile(base_dir, subfolders{j});
 
       if contains(task,'1')
       disp('implementing task 1');
       %REALIGNMENT (Spatial realignment- motion correction)
       % This will run the realign job which will estimate the 6 parameter (rigid body) spatial transformation 
       % that will align the times series of images and will modify the header of the input images(*.hdr),
       % such that they reflect the relative orientation of the data after correction for movement artefacts
        % Generate file paths for Runs
            scans_run = arrayfun(@(i) fullfile(current_subfolder, sprintf(func_files{j}, i, i)), 1:360, 'UniformOutput', false);
            scans_run = scans_run';
            
            job{1}.spm.spatial.realign.estwrite.data = {scans_run};          % Assign .nii files to the job structure
            job{1}.spm.spatial.realign.estwrite.eoptions.quality  = 0.9;     % Estimation option quality 
            job{1}.spm.spatial.realign.estwrite.eoptions.sep      = 4;       % Estimation option separation
            job{1}.spm.spatial.realign.estwrite.eoptions.fwhm     = 5;       % Estimation option smoothing
            job{1}.spm.spatial.realign.estwrite.eoptions.rtm      = 1;       % Estimation option reference volume (1: mean image)
            job{1}.spm.spatial.realign.estwrite.eoptions.interp   = 2;       % Estimation option interpolation
            job{1}.spm.spatial.realign.estwrite.eoptions.wrap     = [0 0 0]; % Estimation option wrapping
            job{1}.spm.spatial.realign.estwrite.eoptions.weight   = '';      % Estimation option weighting
        
            % Reslicing options
            job{1}.spm.spatial.realign.estwrite.roptions.which    = [2 1];   % Resampling option (1: all images)
            job{1}.spm.spatial.realign.estwrite.roptions.interp   = 4;       % Resampling option (4th degree B-spline)
            job{1}.spm.spatial.realign.estwrite.roptions.wrap     = [0 0 0]; % Resampling option wrapping
            job{1}.spm.spatial.realign.estwrite.roptions.mask     = 1;       % Resampling option mask
            job{1}.spm.spatial.realign.estwrite.roptions.prefix   = 'r';     % Resampling output prefix
            % Run realignment jobs
            spm_jobman('run', job);
      end
    
     %% 
     %COREGISTRATION 
        % SPM will then implement a coregistration between the structural and functional data that maximises the mutual information.
        
    if contains(task,'2')
        disp('implementing task 2'); 
        job{1}.spm.spatial.coreg.estimate.ref = {strcat(base_dir,'\sub-01_task-BTP_run-5_bold','\meanMFBTAPE-0005-00001-000001.nii,1')};
        job{1}.spm.spatial.coreg.estimate.source = {strcat(anatdir,'\MFBTAPE-0024-00001-000001.nii,1')};
        job{1}.spm.spatial.coreg.estimate.other = {''};
        job{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        job{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        job{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        job{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        spm_jobman('run', job);
        
    end
     %% 
    %SEGMENTATION
    %SPM will segment the structural image using the default tissue probabilitymaps as priors 
    % SPM will create gray and white matter images and bias-field corrected structural image
    if contains(task,'3')
        disp('implementing task 3');
        job{1}.spm.spatial.preproc.channel.vols = {strcat(anatdir,'\MFBTAPE-0024-00001-000001.nii,1')};
        job{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        job{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        job{1}.spm.spatial.preproc.channel.write = [0 1];
        job{1}.spm.spatial.preproc.tissue(1).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,1'};
        job{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        job{1}.spm.spatial.preproc.tissue(1).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(2).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,2'};
        job{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        job{1}.spm.spatial.preproc.tissue(2).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(3).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,3'};
        job{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        job{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(4).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,4'};
        job{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        job{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(5).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,5'};
        job{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        job{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        job{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        job{1}.spm.spatial.preproc.tissue(6).tpm = {'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm\TPM.nii,6'};
        job{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        job{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        job{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        job{1}.spm.spatial.preproc.warp.mrf = 1;
        job{1}.spm.spatial.preproc.warp.cleanup = 1;
        job{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        job{1}.spm.spatial.preproc.warp.affreg = 'mni';
        job{1}.spm.spatial.preproc.warp.fwhm = 0;
        job{1}.spm.spatial.preproc.warp.samp = 3;
        job{1}.spm.spatial.preproc.warp.write = [0 1];
        job{1}.spm.spatial.preproc.warp.vox = NaN;
        job{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                                      NaN NaN NaN];
        spm_jobman('run',job) % execute the batch
        
    end
    %% 
     %NORMALISATION 
        % Given that the structural and functional data are in alignment, this can be used to spatially normalise the functional data
        % SPM will then write spatially normalised files to the functional data directory. 
        % These files have the prefix w.
    if contains(task,'4')
        disp('implementing task 4');

         re_scans_run = arrayfun(@(i) fullfile(current_subfolder, sprintf(re_func_files{j}, i, i)), 1:360, 'UniformOutput', false);
         re_scans_run = re_scans_run';
        job{1}.spm.spatial.normalise.write.subj.def = {strcat(anatdir,'\y_MFBTAPE-0024-00001-000001.nii')};
        job{1}.spm.spatial.normalise.write.subj.resample =  re_scans_run;
        job{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
        job{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        job{1}.spm.spatial.normalise.write.woptions.interp = 4;
        job{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        spm_jobman('run',job) % execute the batch
        
    end
     %% 
    if contains(task,'5')
        disp('implementing task 5');
        %NORMALISATION_PART2 
        %If you wish to superimpose a subjects functional activations on their own anatomy 
        % you will also need to apply the spatial normalisation parameters to their (bias-corrected) anatomical image.
        job{1}.spm.spatial.normalise.write.subj.def = {strcat(anatdir,'\y_MFBTAPE-0024-00001-000001.nii')};
        job{1}.spm.spatial.normalise.write.subj.resample = {strcat(anatdir,'\mMFBTAPE-0024-00001-000001.nii,1')};
        job{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                                  78 76 85];
        job{1}.spm.spatial.normalise.write.woptions.vox = [1 1 3];
        job{1}.spm.spatial.normalise.write.woptions.interp = 4;
        job{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        spm_jobman('run',job) % execute the batch
        
    end
     if contains(task,'6')
        disp('implementing task 6');
        %%SMOOTHING
         % Generate file paths for Runs
         norm_scans_run = arrayfun(@(i) fullfile(current_subfolder, sprintf(norm_func_files{j}, i, i)), 1:360, 'UniformOutput', false);
         norm_scans_run = norm_scans_run';
        job{1}.spm.spatial.smooth.data = norm_scans_run;
        job{1}.spm.spatial.smooth.fwhm = [6 6 6];
        job{1}.spm.spatial.smooth.dtype = 0;
        job{1}.spm.spatial.smooth.im = 0;
        job{1}.spm.spatial.smooth.prefix = 's';
        spm_jobman('run',job) % execute the batch
        
     end

 end
%%