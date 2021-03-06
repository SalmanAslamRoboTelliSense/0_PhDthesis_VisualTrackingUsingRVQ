%% This function creates RVQ codevectors.  
%
% It is essentially a wrapper around gen.exe.  The original wrapper written in MFC/C++ by Dr Barnes is
% called Linker.
% 
% This function performs 3 steps:
% 1. Creates the .sml file for RVQ (I call it positiveExamples.raw so that it's easier to view in IrfanView).  
%    This contains all positive examples with a 512 byte header.
% 2. Runs gen.exe for training codebooks
% 3. Runs gen.exe -l to test training vectors and saves results in positiveExamples.idx
%
% This is the only function out of all my work that uses a closed source
% file, gen.exe.  Additionally, I do not have access to the source code of
% that file.
%
% Codebooks are denoted by CB.
%
% In the original RVQ, and my code, the actual training is done by gen.exe.  This software and 
% Dr Barnes' Linker are wrappers around gen.exe.  

% Linker produces the following files in order:
%
% 1. F1.sml: Training 6-planar-posneg snippets are vectorized, and stacked together with a 512 byte header.
% 2. F1.smu: Generated while F1.sml is generated, not used anywhere in RVQ.
% 3. F1.dcbk: Decoder codebook is generated.
% 4. F1.ecbk: Encoder codebook is generated.  The 2 codebooks are generated together using gen.exe
% 5. F1.sml.stat_gen.txt: gen.exe's output is captured to this file.  This is also generated with the codebooks.
% 6. F1Linker.prm: Linker parameters are stored, such as snippet sizes, codebook size, etc.
% 8. F1.sml.stat_bnd_in.txt: The paths taken by the training vectors are stored in this file.  It is generated by bnd_in.exe
% 9. F1.idx: gen.exe -l is run to test training vectors and store their XDRs.
%
% Copyright (C) Salman Aslam.  All rights reserved.
% Data created       : April 17, 2011
% Date last modified : July 27, 2011
%%

function RVQ = RVQ__training(DM2, RVQ)

%---------------
%INITIALIZATIONS
%---------------
    DM2_u8                  =   uint8(DM2);     %design matrix, one D dimensional vector (snippet) per column, N total snippets, D=sw*sh
    M                       =   RVQ.in_4_M;          %number of templates per stage
    maxP                    =   RVQ.in_3_maxP;       %max number of stages
    sw                      =   RVQ.in_6_sw;         %snippet width
    sh                      =   RVQ.in_7_sh;         %snippet height
    targetSNR               =   RVQ.in_5_targetSNR;  %desired SNR
    dir_out                 =   RVQ.in_8_dir_out;    %directory to store results in

%!! attention: these should be parameters but I'm fixing them !!  
    iFlag                   =   0.0005;
    jFlag                   =   0.0005;

%filenames (original names in brackets in comments)
    cfn_trgvec              =   [dir_out 'positiveExamples.raw']; %file 1: vectorized positive examples, (F1.sml)
    cfn_ecbk                =   [dir_out 'codebook.ecbk'];        %file 2: encoder codebooks,            (F1.ecbk)
    cfn_dcbk                =   [dir_out 'codebook.dcbk'];        %file 3, decoder codebooks,            (F1.dcbk)
    cfn_nodes               =   [dir_out 'codebook.nodes'];       %file 4, linked list of training paths,(F1.nodes)
    cfn_gentxt              =   [dir_out 'rvq__trg_verbose.txt']; %file 5, verbose output of gen.exe,    (F1.stat_gen.txt)
    cfn_bndintxt            =   [dir_out 'bnd_in.txt'];           %file 6, verbose output of bnd_in.exe  (F1.stat_bnd_in.txt)
    cfn_trgsoc              =   [dir_out 'positiveExamples.idx']; %file 7, XDRs for training examples,   (F1.idx)

%delete existing training files
                                UTIL_FILE_delete(cfn_trgvec);       %file 1
                                UTIL_FILE_delete(cfn_ecbk);         %file 2
                                UTIL_FILE_delete(cfn_dcbk);         %file 3
                                UTIL_FILE_delete(cfn_nodes);        %file 4
                                UTIL_FILE_delete(cfn_gentxt);       %file 5
                                UTIL_FILE_delete(cfn_bndintxt);     %file 6
                                UTIL_FILE_delete(cfn_trgsoc);       %file 7
%-------------------
%PRE-PROCESSING
%-------------------
    DATAMATRIX_saveInFormat_rvq    (DM2_u8, cfn_trgvec, sw, sh);  %takes DM2 as input and writes it to a file

    
%-------------------
%PROCESSING
%-------------------
    
    if (ispc)

        if (maxP==8)
            system(['RVQ__training_gen8.exe    ' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -i' num2str(iFlag) ' -j' num2str(jFlag) ' > ' cfn_gentxt]);
        elseif (maxP==16)
            system(['RVQ__training_gen16.exe   ' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -i' num2str(iFlag) ' -j' num2str(jFlag) ' > ' cfn_gentxt]);
        end

    elseif (isunix)

        if (maxP==8)
            system(['./RVQ__training_gen8.linux ' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -i' num2str(iFlag) ' -j' num2str(jFlag) ' > ' cfn_gentxt]);            
        elseif (maxP == 16)
            system(['./RVQ__training_gen16.linux' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -i' num2str(iFlag) ' -j' num2str(jFlag) ' > ' cfn_gentxt]);
        end
    end


%-------------------
%POST-PROCESSING
%-------------------
%save model
    %decoder codebook to get actual stages, codebooks
    [RVQ.mdl_1_P__1x1, M_check, sw_check, sh_check, CBr_DxMP, CBg_DxMP, CBb_DxMP]  ...
                            =  RVQ_FILES_read_dcbk_file        (cfn_dcbk); 
                        
                        
    RVQ.mdl_3_CB_DxMP       =   CBr_DxMP;     %CB: single channel codebook
    
    %error checking
    if (M ~= M_check || sw ~= sw_check || sh ~= sh_check)
        disp('ERROR: M, sw, or sh not correct')
    end   

%test training examples
    RVQ.in_2_mode           =   'trg';
    RVQ                     =   RVQ__testing_grayscale(DM2, RVQ); %my matlab code for gen.exe -l
    RVQ.in_2_mode           =   'tst';
    
    
    

    
    
    
    
    
    

    %RVQ.trg_SNRdB_file                 =   RVQ_FILES_read_dSNR_from_genstat_file(cfn_gentxt);  %use this line if you want to see what training 
                                            %SNR RVQ reports.  i checked and it uses all 6 channels.  if i use all 6 channels, 
                                            %then my reported value and this value reported by RVQ are exactly the same.
    
    
    
%     method 2: gen.exe -l (method 1 and 2 give the same answer, except in
%                           very rare cases where my matlab code is more accurate.  refer to
%                           main_compare_bPCA_ESVQ_RVQ_TSVQ.m for more details)
%     if (ispc)
% 
%         if (maxP==8)
%             system(['RVQ__training_gen8.exe    ' cfn_trgvec  ' ' cfn_ecbk ' ' cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -l']);
%         elseif (maxP==16)
%             system(['RVQ__training_gen16.exe   ' cfn_trgvec  ' ' cfn_ecbk ' ' cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -l']);
%         end
% 
%     elseif (isunix)
% 
%         if (maxP==8)
%             system(['./RVQ__training_gen8.linux ' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -l']);
%         elseif (maxP == 16)
%             system(['./RVQ__training_gen16.linux' cfn_trgvec  ' ' cfn_ecbk ' '  cfn_dcbk ' ' num2str(M+1) ' -S' num2str(targetSNR) ' -l']);        
%         end
%     end
%     RVQ.trg_1_descr_PxN     =   RVQ_FILES_read_idx_file('positiveExamples.idx', maxP, M, true);    %notice that I do not use actualP but maxP




%-------------------
%OLD CODE no longer used but here just in case, and to see evolution
%-------------------    
%bnd_in
    %bnd_in.exe displays the information produced by gen.exe -l, i.e. XDRs of training vectors as a linked list in the F1.nodes file.  
    %I'm not using it since I get my training XDRs from my Matlab code above or gen.exe -l.  No need for this added complexity.
    
    %system(['RVQ_1b_train_bndin8.exe           '     cfn_trgvec   ' ' cfn_ecbk     ' '  cfn_dcbk     ' ' num2str(M+1)  ' '   '-S' num2str(targetSNR)    ' -i' num2str(iFlag)    ' -j' num2str(jFlag)    ' > ' cfn_bndintxt]);    
    %system(['./RVQ_1b_train_bndin8.linux       '     cfn_trgvec  ' ' cfn_ecbk      ' '  cfn_dcbk     ' ' num2str(M+1)  ' '   '-S' num2str(targetSNR)    ' -i' num2str(iFlag)    ' -j' num2str(jFlag)    ' > ' cfn_bndintxt]);    

%input training file
    %RVQ needs training snippets (vectors) in a certain format in a file.  Currently I call it positiveExamples.raw
    %Initially, I was creating it with my C++ file called RVQ_0_create_posraw.exe.  Now, I do it with Matlab using the function
    %DATAMATRIX_saveInFormat_rvq

    %system(['RVQ_0_create_posraw.exe           '     cfn_poscsv   ' ' num2str(sw)  ' '  num2str(sh)  ' ' cfn_trgvec]);
    %system(['./RVQ_0_create_posraw.linux       '     cfn_poscsv  ' ' num2str(sw)   ' '  num2str(sh)  ' ' cfn_trgvec]);    