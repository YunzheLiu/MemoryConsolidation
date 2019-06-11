function average_nonconsec_correlation_maps(numPairs, OutputFolder) %leave out neigbor pairs

  m = int16(1);
 %n is number of files already counted
 n = int16(1);

 %input_folder = fullfile(Root,Subjects{indexx});
 InputFolder = OutputFolder;
 %fill empty matrix up with zeros
 totals = [];
 for x = 1:61
     for y = 1:73
         for z = 1:61
             totals(x,y,z) = 0;
         end
     end
 end
 disp('initialized totals array');
 useless = 0;
 temp_vol = [];
    
 while m < 10000 %will clearly finish by 10000, max number is 2526

     %if exist(fullfile(input_folder, strcat('rsa', int2str(m), '_zscore.nii')), 'file')
    if exist(fullfile(InputFolder, strcat('rsa', int2str(m), '_corr.nii')), 'file')
        if (m == 12 || m == 23 || m == 34 || m == 45 || m == 56 || m == 67 || m == 78 ... %Avoiding coliniearity between neighbouring trials
            || m == 89 || m == 910 || m == 1011 || m == 1112 || m == 1213 || m == 1314 ...
            || m == 1415 || m == 1516 || m == 1617 || m == 1718 || m == 1819 ...
            || m == 1920 || m == 2021 || m == 2122 || m == 2223 || m == 2324 ...
            || m == 2425 || m == 2526 || m == 2627 || m == 13 || m == 24 || m == 35 ...
            || m == 46 || m == 57 || m == 68 || m == 79 || m == 810 || m == 911 || m == 1012 ...
            || m == 1113 || m == 1214 || m == 1315 || m == 1416 || m == 1517 || m == 1618 ...
            || m == 1719 || m == 1820 || m == 1921 || m == 2022 || m == 2123 || m == 2224 ...
            || m == 2325 || m == 2426 || m == 2527 || m == 2628)

            useless = useless + 1;
         else
                %vol = spm_vol(fullfile(input_folder, strcat('rsa', int2str(m), '_zscore.nii')));
             vol = spm_vol(fullfile(InputFolder, strcat('rsa', int2str(m), '_corr.nii')));
             temp_vol = vol;
             array = spm_read_vols(vol);
             for i = 1:61
                  for j = 1:73
                      for k = 1:61
                            totals(i,j,k) = totals(i,j,k) + array(i,j,k);
                      end
                  end 
             end
        end
            
        m = m+1;
        n = n+1;

    else
        m = m+1;
    end 
  end
        
  n = n-1;

  disp('...........computing averages...');
  average = totals;
  zaverage = zeros(61,73,61);

  for a = 1:61
      for b = 1:73
          for c = 1:61
              average(a,b,c) = double(totals(a,b,c))/double((n - useless));
              zaverage(a,b,c) = log((1+average(a,b,c))/(1-average(a,b,c)))*0.5;
          end
      end
  end
  DIM          = [61, 73, 61];
  [x,y,z]      = ndgrid(1:DIM(1), 1:DIM(2), 1:DIM(3));
  XYZ          = [x(:)';y(:)';z(:)']; clear x y z 

  vol = spm_vol(fullfile(InputFolder, strcat('rsa', int2str(12), '_corr.nii')));
  temp_vol = vol;
  VO = deal(struct(...
      'fname',   [],...
      'dim',     DIM,...
      'dt',      [spm_type('float64') spm_platform('bigend')],...
      'mat',     temp_vol.mat,...
      'pinfo',   [1 0 0]',...
      'descrip', 'Searchlight_Result'));

   VO.fname = [InputFolder, '/averaged_trialwise_rsa_zscore_nonconsec_skip2neighbors.nii'];

   spm_write_vol(VO, average);
   delete(fullfile(InputFolder, strcat('rsa*_corr.nii')));
   %delete(fullfile(InputFolder, strcat('rsa*_corr.nii')), 'file');
end
