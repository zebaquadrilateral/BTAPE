% Define the main directory and log files
main_dir = 'C:\Users\mcnbf\Downloads\spm12\spm12\fMRI\BTAPE\Localizer\log_files';
log_files = {'log_sub-001_BTAPE_localizer1__time-15-41.mat', 'log_sub-001_BTAPE_localizer2__time-15-48.mat'};

% Initialize arrays to store extracted data
conditions = {};
onset_times = [];

% Loop over each log file to extract conditions and onset times
for i = 1:numel(log_files)
    % Load the current log file
    log_file_path = fullfile(main_dir, log_files{i});
    data = load(log_file_path);
    
    % Extract the conditions and onset times from the loaded data
    % Assuming the structure of the data contains fields 'condition_names' and 'onsets'
    % Adjust the field names according to your specific log file structure
    if isfield(data, 'condition_names') && isfield(data, 'onsets')
        conditions = [conditions; data.condition_names(:)]; % Append conditions
        onset_times = [onset_times; data.onsets(:)]; % Append onsets
    else
        warning('The log file %s does not contain the expected fields.', log_files{i});
    end
end

% Display the extracted conditions and onset times
disp('Extracted Conditions:');
disp(conditions);
disp('Extracted Onset Times:');
disp(onset_times);

% Save the extracted parameters to a new .mat file (optional)
output_file = fullfile(main_dir, 'extracted_conditions_onsets.mat');
save(output_file, 'conditions', 'onset_times');
