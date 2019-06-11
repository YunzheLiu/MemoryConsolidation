%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rsa_wholebrain_correct_T_recent (paralist)
CurrentDir = pwd;

ServerPath   = strtrim(paralist.ServerPath);
SubjectList  = strtrim(paralist.SubjectList);
MapType      = strtrim(paralist.MapType);
MapIndex     = paralist.MapIndex;
SessCon      = paralist.SessCon;
MaskFile     = strtrim(paralist.MaskFile);
% StatsFolder  = strtrim(paralist.StatsFolder);
OutputDir    = strtrim(paralist.OutputDir);
SearchShape  = strtrim(paralist.SearchShape);
SearchRadius = paralist.SearchRadius;

disp('-------------- Contents of the Parameter List --------------------');
disp(paralist);
disp('------------------------------------------------------------------');
clear paralist;
disp('==================================================================');
disp('rsa_trialwise_wholebrain.m is running');
fprintf('Current directory is: %s\n', pwd);
% fprintf('Config file is: %s\n', ConfigFile);
disp('------------------------------------------------------------------');
disp('==================================================================');
fprintf('\n');

Subjects = SubjectList;
NumSubj = length(Subjects);
nSS = SessCon(1);
nCon = SessCon(2);

for iSubj = 1:NumSubj
  display(strcat('Processing subject: ', Subjects{iSubj}, '; ', int2str(iSubj), '/', int2str(length(Subjects)))); 
  DataDir = fullfile(ServerPath, Subjects{iSubj});     
  spm_mat = load(fullfile(DataDir, 'SPM.mat'));
  SPM = spm_mat.SPM;
  design_mtx = SPM.xX.name;
  nReg = nCon; %Number of regressors of each session

  cnt = 0;
  nCorr = 0;
  Indices = zeros(nSS*nCon,1);
  for i = 1:size(design_mtx,2)
        if length(design_mtx{i}) >= 19 %taking substring of "Sn(1) NT_Remote_face1*bf(1)"
            if strcmpi(design_mtx{i}(7:19), 'T_Recent_face')
                nCorr = nCorr + 1;
                if i < 37 
                    CorrIndex(nCorr,1) = i; 
                end
            end
        end       
  end
  
  NumMap = nCorr;
  VY = cell(NumMap, 1);
  MapName = cell(NumMap, 1);
  
  switch lower(MapType)
    case 'tmap'
      for i = 1:NumMap
        VY{i} = fullfile(DataDir, SPM.xCon(CorrIndex(i)).Vspm.fname);
        MapName{i} = SPM.xCon(CorrIndex(i)).name;      
      end
    case 'conmap'
      for i = 1:NumMap
         VY{i} = fullfile(DataDir, SPM.xCon(CorrIndex(i)).Vcon.fname);
         MapName{i} = SPM.xCon(CorrIndex(i)).name;
      end
  end
  
  if isempty(MaskFile)
    VM = fullfile(DataDir, SPM.VM.fname);
  else
    VM = MaskFile;
  end
  
  OutputFolder = fullfile(OutputDir, Subjects{iSubj});
  if ~exist(OutputFolder, 'dir')
    mkdir(OutputFolder);
  end
  %k = 1;
  numPairs = NumMap * (NumMap - 1)/2;
   parfor i = 1:NumMap
      display(strcat('...Computing map: ', int2str(i), '..writing out ...'));
      for j = i+1:NumMap
        %display(strcat(int2str(k), ' ', 'of', ' ', int2str(numPairs)));
        %k = k+1;
        FileEnd = strcat('rsa', int2str(i), int2str(j));
        OutputFile = fullfile(OutputFolder, FileEnd);
        SearchOpt = struct('def', 'sphere', 'spec', 6);
        SearchOpt.def = SearchShape;
        SearchOpt.spec = SearchRadius;
        
        CurrentMaps = cell(2,1);
        CurrentMaps{1} = VY{i};
        CurrentMaps{2} = VY{j};        
        Searchlight_Yunzhe(CurrentMaps, VM, SearchOpt, 'pearson_correlation', OutputFile);
      end 
  end
  display(strcat('Averaging maps subject: ', Subjects{iSubj}, '; ', int2str(iSubj), '/', int2str(length(Subjects))));
  average_nonconsec_correlation_maps(numPairs, OutputFolder);
end

disp('-----------------------------------------------------------------');
fprintf('Changing back to the directory: %s \n', CurrentDir);
cd(CurrentDir);
disp('Wholebrain RSA is done.');
clear all;
close all;
end

