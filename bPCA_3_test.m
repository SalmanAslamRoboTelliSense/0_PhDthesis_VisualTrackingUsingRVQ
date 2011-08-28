%Q is how many dimensions you want to retain
%D is number of pixels, i.e. dimensions
%N is number of images

function BPCA = bPCA_3_test(x_Dx1, BPCA)

%--------------------------------------------
% PRE-PROCESSING
%--------------------------------------------
        U_DxN                       =   BPCA.mdl_2_U_DxN;
        mu_Dx1                      =   BPCA.mdl_1_mu_Dx1;
        Q                           =   BPCA.Q;
        
        [D, N]                      =   size(x_Dx1);        %U_DxN is DxD if N>D, otherwise it's DxN
        xz_Dx1                      =   x_Dx1 - mu_Dx1;     %zero centered, i.e., mean removed

%--------------------------------------------
% PROCESSING
%--------------------------------------------      
    %scalar projection on each of the N dimensions (I'm assuming D > N, so only N eigenvectors)
        BPCA.tst_1_descriptor_Dx1   =   U_DxN' * xz_Dx1; %projection scalars
              
    %reconstruction
        temp                        =   min(N, Q);
        BPCA.tst_2_recon_Dx1        =   U_DxN(:,1:temp) * BPCA.tst_1_descriptor_Dx1(1:temp,:) + repmat(mu_Dx1, 1, N); %tst1. reconstructed signal

%--------------------------------------------
% POST-PROCESSING
%--------------------------------------------        
%4 part testing results
    BPCA.tst_3_err_Dx1                =   x_Dx1 - BPCA.tst_2_recon_Dx1;                             %tst2. reconstruction error
    BPCA.tst_4_SNRdB                  =   UTIL_METRICS_compute_SNRdB(x_Dx1, BPCA.tst_3_err_Dx1);    %tst3. SNRdB
    BPCA.tst_5_rmse                   =   UTIL_METRICS_compute_rms_value(BPCA.tst_3_err_Dx1);       %tst4. rmse