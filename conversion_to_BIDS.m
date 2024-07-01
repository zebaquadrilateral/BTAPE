% Define directories and patient IDs
ddir = 'C:\Users\zebaq\Documents\MATLAB\fMRI\BTAPE';
patdir = {'01','05'};
files_01 = {'anat_t1w_mprage_sag_p2_0.8mm_24__MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_5_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_8_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_11_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_14_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_17_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_19_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_21_MR'};
files_05 = {'anat_t1w_mprage_sag_p2_0.8mm_2MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_4_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_5_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_6_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_7_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_8_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_9_MR', ...
            'ep2d_func_task-BTP_dir-AP_bold_10_MR'};

% Define BIDS directory
bids_dir = fullfile(ddir, 'BIDS');
if ~exist(bids_dir, 'dir')
    mkdir(bids_dir);
end

% Process each patient
for i = 1:length(patdir)
    pat_id = patdir{i};
    src_files = eval(['files_' pat_id]); % Get the list of files for the current patient
    sub_dir = fullfile(bids_dir, ['sub-' pat_id]);
    
    % Create subject directories
    anat_dir = fullfile(sub_dir, 'anat');
    func_dir = fullfile(sub_dir, 'func');
    
    for j = 1:length(src_files)
        src_file = src_files{j};
        if contains(src_file, 'anat_t1w')
            dest_file = ['sub-' pat_id '_T1w.nii'];
            move_and_rename(fullfile(ddir, pat_id), src_file, anat_dir, dest_file);
        elseif contains(src_file, 'bold')
            task_run = regexp(src_file, 'bold_(\d+)_MR', 'tokens', 'once');
            dest_file = ['sub-' pat_id '_task-BTP_run-' task_run{1} '_bold.nii'];
            move_and_rename(fullfile(ddir, pat_id), src_file, func_dir, dest_file);
        end
    end
end

disp('Conversion to BIDS format completed.');

% Helper function to move and rename files
function move_and_rename(src_dir, src_file, dest_dir, dest_file)
    if ~exist(dest_dir, 'dir')
        mkdir(dest_dir);
    end
    movefile(fullfile(src_dir, src_file), fullfile(dest_dir, dest_file));
end
