
% Define the data directory
ddir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE';
patdir = {'05'};
datadir = fullfile(ddir, patdir);

% List of subdirectories containing DICOM files
subdirs = {'anat_t1w_mprage_sag_p2_0.8mm_2MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_4_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_5_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_6_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_7_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_8_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_9_MR', ...
    'ep2d_func_task-BTP_dir-AP_bold_10_MR'};

% Initialize SPM
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; % SPM present working directory
addpath(spmdir)
spm_jobman('initcfg')

% Initialize job structure
job = [];

% Loop over each subdirectory to list and convert DICOM files
for i = 1:length(subdirs)
    current_dir = fullfile(datadir{1}, subdirs{i});
    
    % List all DICOM files in the current directory
    dcm_files = spm_select('FPList', current_dir, '^.*\.dcm$');
    
    % Check if any DICOM files are found
    if isempty(dcm_files)
        warning('No DICOM files found in directory: %s', current_dir);
        continue;
    end
    
    % Display the current directory and number of DICOM files found
    fprintf('Converting DICOM files from directory: %s\n', current_dir);
    fprintf('Number of DICOM files found: %d\n', size(dcm_files, 1));
    
    % Add to job structure for DICOM to NIfTI conversion
    job{end+1}.spm.util.import.dicom.data = cellstr(dcm_files);
    job{end}.spm.util.import.dicom.root = 'flat';
    job{end}.spm.util.import.dicom.outdir = {current_dir}; % Save NIfTI files in the same directory
    job{end}.spm.util.import.dicom.protfilter = '.*';
    job{end}.spm.util.import.dicom.convopts.format = 'nii';
    job{end}.spm.util.import.dicom.convopts.meta = 0;
end

% Run the job if there are any valid DICOM files
if ~isempty(job)
    spm_jobman('run', job);
else
    error('No valid DICOM files found for conversion.');
end


