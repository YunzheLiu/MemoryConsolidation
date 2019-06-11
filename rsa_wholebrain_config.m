clear;
clc;
% Please specify the path to the folder holding subjects
paralist.ServerPath = 'H:\MVPA\RSA_Yunzhe\first_level_condition_by_condition';

paralist.SubjectList = {'Sub_023','Sub_025','Sub_027','Sub_028','Sub_032','Sub_040','Sub_047','Sub_049','Sub_050','Sub_051','Sub_053','Sub_054','Sub_056','Sub_057','Sub_058','Sub_059','Sub_060','Sub_061'};

% Please specify whether to use t map or beta map ('tmap' or 'conmap')
paralist.MapType = 'conmap';

paralist.SessCon = [1, 4]; %Number of sessions and number of contrasts each session
paralist.MapIndex = [1:1:4];

% Please specify the mask file, if it is empty, it uses the default one from SPM.mat
paralist.MaskFile = 'E:\Program Files\MATLAB\R2014a\toolbox\spm12\apriori\grey.nii';

% Please specify the path to the folder holding analysis results
paralist.OutputDir = 'H:\MVPA\RSA_Yunzhe\condition_by_condition_RSA\participants';

%--------------------------------------------------------------------------
paralist.SearchShape = 'sphere';
paralist.SearchRadius = 6; % in mm
%--------------------------------------------------------------------------
