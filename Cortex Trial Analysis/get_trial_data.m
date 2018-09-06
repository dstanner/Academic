clc; clear all

% Get subject numbers by task and whether they were ICAed 
% (ICAed trial data is in different folders from the non-ICAed data
AgrLexAux_No_ICA = csvread('AgrLexAux_No_ICA_ppts.csv', 1);
AgrLexAux_ICA = csvread('AgrLexAux_ICA_ppts.csv', 1);
AGLA_No_ICA = csvread('AGLA_No_ICA_ppts.csv', 1);
AGLA_ICA = csvread('AGLA_ICA_ppts.csv', 1);


eeglab

N4_window = [300 500];
P6_window = [500 800];

% All of the subjects
subjects = [101	102	103	105	111	112	113	114	115	116	117	118	119	...
    120	121	122	123	124	125	126	127	128	129	131	132	133	134	135	...
    136	137	138	140	141	142	143	145	146	147	148	149	151	152	153	...
    155	156	157	158	159	160	161	162	163	164	165	166	167	168	170	...
    172	175	176	177	178	179	180	182	301	302	303	304	305	306	307	...
    308	309	310	311	312	313	314	315	316	317	318	320	321	322	323	...
    324	326	327	329	330	331	333	335	336	337	338	339	340	341	342	...
    343	344	345	346	347	349	351	352	353	354	355];

% Convert to string cell
subjects = sprintfc('%d', subjects);

% Initialize output containers
N4_outs = [];
P6_outs = [];

for s=1:length(subjects)
  
    curr_sub = subjects{s};
    sub_num = str2num(curr_sub);
    
    % Set data directories to read data from
    if ismember(sub_num, AgrLexAux_No_ICA)
        datadir = ['/Volumes/LACIE SHARE/Experiments/AgrLexAux/' ...
            '/EEG Data/Session 1 Sentence/No ICA AR Datasets/'];
    elseif ismember(sub_num, AgrLexAux_ICA)
        datadir = ['/Volumes/LACIE SHARE/Experiments/AgrLexAux/'...
            'EEG Data/Session 1 Sentence/ICA AR Datsets'];
    else 
        datadir = ['/Volumes/LACIE SHARE/Experiments/AGLA_SP/' ...
            '/Analysis/Ar Datasets'];
    end
    
    % Set subject data file name
    if sub_num < 200 % RSVP
        filename = [curr_sub 's1_AR.set'];
    elseif sub_num > 200 % SPR
        filename = [curr_sub '_ardata.set'];
    end
    
    % Get the epoched data
    EEG = pop_loadset(filename, datadir);
    
    % Get epoch and bin info
    epochs = zeros(size(EEG.EVENTLIST.eventinfo, 2), 1);
    bins = zeros(size(EEG.EVENTLIST.eventinfo, 2), 1);
    index = zeros(size(EEG.EVENTLIST.eventinfo, 2), 1);
    
    for i=1:length(epochs)
        epochs(i) = EEG.EVENTLIST.eventinfo(i).bepoch;
        bins(i) = EEG.EVENTLIST.eventinfo(i).bini(1); % The first entry always has the critical bin
        index(i) = EEG.EVENTLIST.eventinfo(i).item;
    end
    
    bins = bins(epochs ~= 0);
    index = index(epochs ~= 0);
    epochs = epochs(epochs ~= 0);

    
    % Get rejection info
    rejects = EEG.reject.rejmanual';
    
    % Get sample indices in the two time windows
    N4_inds = find(EEG.times >= N4_window(1) & EEG.times <= N4_window(2));
    P6_inds = find(EEG.times >=P6_window(1) & EEG.times <= P6_window(2));
    
    N4_means = [];
    P6_means = [];
    N4_means = squeeze(mean(EEG.data(:, N4_inds, :), 2))';
    P6_means = squeeze(mean(EEG.data(:, P6_inds, :), 2))';
    
    % Add this data to the matrices of mean amplitudes
    N4_means = [N4_means index epochs bins rejects];
    P6_means = [P6_means index epochs bins rejects];
    
    % Add subject ID column
    N4_means = [N4_means ones(size(N4_means, 1), 1)*sub_num];
    P6_means = [P6_means ones(size(P6_means, 1), 1)*sub_num];
    
    % Add to output container
    N4_outs = [N4_outs; N4_means];
    P6_outs = [P6_outs; P6_means];

    
end

% Create column headers
% Start with channels
chans = strings(1, 34);
for i=1:length(chans)
    chans(i) = EEG.chanlocs(i).labels;
end
   
% Add Epochs, Bins, and Rejections, 
Col_labels = cellstr([chans 'Index' 'Epoch' 'Bin' 'Rejected' 'Subject']);



% Make tables for output
N4_table = array2table(N4_outs, 'VariableNames', Col_labels);
P6_table = array2table(P6_outs, 'VariableNames', Col_labels);

% Get rid of non-critical bins
N4_table = N4_table(ismember(N4_table.Bin, [1:4]),:);
P6_table = P6_table(ismember(P6_table.Bin, [1:4]),:);

% save output
writetable(N4_table, 'N4_trial_amplitudes.csv');
writetable(P6_table, 'P6_trial_amplitudes.csv');
    
