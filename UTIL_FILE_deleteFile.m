function UTIL_FILE_deleteFile(cfn)   %cfn is complete file name

    if      (ispc)      [status, result] = system(['del ' cfn]);
    elseif  (isunix)    [status, result] = unix(['rm ' cfn]);
    end
                                 
    
    
    
