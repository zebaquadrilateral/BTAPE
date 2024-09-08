% Initialize SPM
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM working directory:
addpath(spmdir)
spm('defaults', 'FMRI');
spm_jobman('initcfg');

specdir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BTAPE_jobs\GLM_localizer';
% Base directories for runs
run21_base_dir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BIDS\sub-01\func\Localizer_func\sub-01_task-BTP_run-21_bold.nii\';
run23_base_dir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BIDS\sub-01\func\Localizer_func\sub-01_task-BTP_run-23_bold.nii\';

% Generate file paths for Run 21
scans_run21 = arrayfun(@(i) fullfile(run21_base_dir, sprintf('swrMFBTAPE-0021-%05d-%06d.nii,1', i, i)), 1:360, 'UniformOutput', false);

% Generate file paths for Run 23
scans_run23 = arrayfun(@(i) fullfile(run23_base_dir, sprintf('swrMFBTAPE-0023-%05d-%06d.nii,1', i, i)), 1:360, 'UniformOutput', false);


% job script
job =[];
job{1}.spm.stats.fmri_spec.dir = {specdir};
job{1}.spm.stats.fmri_spec.timing.units = 'secs';
job{1}.spm.stats.fmri_spec.timing.RT = 1;
job{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
job{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% Session 1 (Run 21)
job{1}.spm.stats.fmri_spec.sess(1).scans = scans_run21';
job{1}.spm.stats.fmri_spec.sess(1).cond(1).name = 'Left';
job{1}.spm.stats.fmri_spec.sess(1).cond(1).onset = [2 42 62 142 222 262 282 302 342];
job{1}.spm.stats.fmri_spec.sess(1).cond(1).duration = 8;
job{1}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
job{1}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
job{1}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
job{1}.spm.stats.fmri_spec.sess(1).cond(2).name = 'Right';
job{1}.spm.stats.fmri_spec.sess(1).cond(2).onset = [22 82 102 122 162 182 202 242 322];
job{1}.spm.stats.fmri_spec.sess(1).cond(2).duration = 8;
job{1}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
job{1}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
job{1}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
job{1}.spm.stats.fmri_spec.sess(1).multi = {''};
job{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
job{1}.spm.stats.fmri_spec.sess(1).multi_reg = {fullfile(run21_base_dir, 'rp_MFBTAPE-0021-00001-000001.txt')};
job{1}.spm.stats.fmri_spec.sess(1).hpf = 128;

% Session 2 (Run 23)
job{1}.spm.stats.fmri_spec.sess(2).scans = scans_run23';
job{1}.spm.stats.fmri_spec.sess(2).cond(1).name = 'Left';
job{1}.spm.stats.fmri_spec.sess(2).cond(1).onset = [2 42 62 142 222 262 282 302 342];
job{1}.spm.stats.fmri_spec.sess(2).cond(1).duration = 8;
job{1}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
job{1}.spm.stats.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
job{1}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;
job{1}.spm.stats.fmri_spec.sess(2).cond(2).name = 'Right';
job{1}.spm.stats.fmri_spec.sess(2).cond(2).onset = [22 82 102 122 162 182 202 242 322];
job{1}.spm.stats.fmri_spec.sess(2).cond(2).duration = 8;
job{1}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;
job{1}.spm.stats.fmri_spec.sess(2).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
job{1}.spm.stats.fmri_spec.sess(2).cond(2).orth = 1;
job{1}.spm.stats.fmri_spec.sess(2).multi = {''};
job{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
job{1}.spm.stats.fmri_spec.sess(2).multi_reg = {fullfile(run23_base_dir, 'rp_MFBTAPE-0023-00001-000001.txt')};
job{1}.spm.stats.fmri_spec.sess(2).hpf = 128;

% Remaining parameters
job{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
job{1}.spm.stats.fmri_spec.bases.fir.length = 16;% basis function selected is finite impulse response with window length as 16 
job{1}.spm.stats.fmri_spec.bases.fir.order = 16; %finite impulse response with order 16 
job{1}.spm.stats.fmri_spec.volt = 1;
job{1}.spm.stats.fmri_spec.global = 'None';
job{1}.spm.stats.fmri_spec.mthresh = 0.8;
job{1}.spm.stats.fmri_spec.mask = {'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE\BIDS\sub-01\anat\sub-01_T1w\c1MFBTAPE-0024-00001-000001.nii,1'}; %explicitly masking with the structural image 
job{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm_jobman('run', job);

%% %Estimation
job = [];
job{1}.spm.stats.fmri_est.spmmat = {strcat(specdir,'\SPM.mat')};
job{1}.spm.stats.fmri_est.write_residuals = 0;
job{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',job)
