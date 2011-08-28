

    %-----------------------------------------------            
    %save images
    %-----------------------------------------------

        UTIL_saveimg_wholeFigure(h2, cfn_Ioverlaid);

    %-----------------------------------------------            
    %save csv files
    %-----------------------------------------------
        
        
        %1. affine parameters
        clear struct1;
                        struct1.data     =   trkIPCA.best_affineROI_1x6;                                                                                           UTIL_savecsv_struct(trkIPCA.cfn_1_affine_1x6, f, struct1);
        if (bUseBPCA )   struct1.data     =   trkBPCA.best_affineROI_1x6;                                                                                           UTIL_savecsv_struct(trkBPCA.cfn_1_affine_1x6, f, struct1); end
        if (bUseRVQ)    struct1.data     =   trkRVQ.best_affineROI_1x6;                                                                                           UTIL_savecsv_struct(trkRVQ.cfn_1_affine_1x6, f, struct1); end
        if (bUseTSVQ)   struct1.data     =   trkTSVQ.best_affineROI_1x6;                                                                                           UTIL_savecsv_struct(trkTSVQ.cfn_1_affine_1x6, f, struct1); end

        %2. feature points
        clear struct1;
                        j=1;for i = 1:size(GT, 2) struct1.data(j) = GT(1,i,f);j=j+1;struct1.data(j) =       GT(2,i,f);j=j+1;end;                           UTIL_savecsv_struct(cfn_2_GTFP,  f, struct1);
                        j=1;for i = 1:size(GT, 2) struct1.data(j) = trkIPCA.FP_est(1,i,f);j=j+1;struct1.data(j) = trkIPCA.FP_est(2,i,f);j=j+1;end;                           UTIL_savecsv_struct(trkIPCA.cfn_2_FP,  f, struct1);
        if (bUseBPCA )   j=1;for i = 1:size(GT, 2) struct1.data(j) = BPCA.FP_est(1,i,f);j=j+1;struct1.data(j) = BPCA.FP_est(2,i,f);j=j+1;end;                           UTIL_savecsv_struct(trkBPCA.cfn_2_FP,  f, struct1); end
        if (bUseRVQ)    j=1;for i = 1:size(GT, 2) struct1.data(j) = RVQ.FP_est(1,i,f);j=j+1;struct1.data(j) = RVQ.FP_est(2,i,f);j=j+1;end;                           UTIL_savecsv_struct(trkRVQ.cfn_2_FP,  f, struct1); end
        if (bUseTSVQ)   j=1;for i = 1:size(GT, 2) struct1.data(j) = TSVQ.FP_est(1,i,f);j=j+1;struct1.data(j) = TSVQ.FP_est(2,i,f);j=j+1;end;                           UTIL_savecsv_struct(trkTSVQ.cfn_2_FP,  f, struct1); end
                        

        %3. tracking error
        clear struct1;
                        struct1.data(1) = trkIPCA.FPerr(f);                struct1.data(2) = trkIPCA.FPerr_avg(f);                                                             UTIL_savecsv_struct(trkIPCA.cfn_3_trk_rmse,      f, struct1);
        if (bUseBPCA )   struct1.data(1) = BPCA.FPerr(f);                struct1.data(2) = BPCA.FPerr_avg(f);                                                             UTIL_savecsv_struct(trkBPCA.cfn_3_trk_rmse,      f, struct1); end
        if (bUseRVQ)    struct1.data(1) = RVQ.FPerr(f);                struct1.data(2) = RVQ.FPerr_avg(f);                                                             UTIL_savecsv_struct(trkRVQ.cfn_3_trk_rmse,      f, struct1); end
        if (bUseTSVQ)   struct1.data(1) = TSVQ.FPerr(f);                struct1.data(2) = TSVQ.FPerr_avg(f);                                                             UTIL_savecsv_struct(trkTSVQ.cfn_3_trk_rmse,      f, struct1); end
        
        
        %4. training error (rmse, avg rmse, snr)
	if (Ntrg_snp             >=  CONFIG.trg_B) %i.e.train every batchsize images
        clear struct1;
                        struct1.data(1) = IPCA.trg_SNRdB;          struct1.data(2) =  IPCA.trg_rmse;         struct1.data(3) = temp1;                         UTIL_savecsv_struct(trkIPCA.cfn_4_trg_rmse,      f, struct1);
        if (bUseBPCA )   struct1.data(1) = BPCA.trg_SNRdB;          struct1.data(2) =  BPCA.trg_rmse;         struct1.data(3) = temp2;                         UTIL_savecsv_struct(trkBPCA.cfn_4_trg_rmse,      f, struct1); end
        if (bUseRVQ)    struct1.data(1) = RVQ.trg_SNRdB;          struct1.data(2) =  RVQ.trg_rmse;         struct1.data(3) = temp3;                         UTIL_savecsv_struct(trkRVQ.cfn_4_trg_rmse,      f, struct1); end
        if (bUseTSVQ)   struct1.data(1) = TSVQ.trg_SNRdB;          struct1.data(2) =  TSVQ.trg_rmse;         struct1.data(3) = temp4;                         UTIL_savecsv_struct(trkTSVQ.cfn_4_trg_rmse,      f, struct1); end
    end
        
        %5. testing error (rmse, avg rmse, snr)
        clear struct1;
                        struct1.data(1) = trkIPCA.tst_SNRdB;      struct1.data(2) =  trkIPCA.tst_rmse;     struct1.data(3) = trkIPCA.tst_RMSEavg_Fx1(f);        UTIL_savecsv_struct(trkIPCA.cfn_5_tst_rmse,       f, struct1);
        if (bUseBPCA )   struct1.data(1) = trkBPCA.tst_SNRdB;      struct1.data(2) =  trkBPCA.tst_rmse;     struct1.data(3) = bpca_tst_avgrmse(f);        UTIL_savecsv_struct(trkBPCA.cfn_5_tst_rmse,       f, struct1); end
        if (bUseRVQ)    struct1.data(1) = trkRVQ.tst_SNRdB;      struct1.data(2) =  trkRVQ.tst_rmse;     struct1.data(3) = rvq__tst_avgrmse(f);        UTIL_savecsv_struct(trkRVQ.cfn_5_tst_rmse,       f, struct1); end
        if (bUseTSVQ)   struct1.data(1) = trkTSVQ.tst_SNRdB;      struct1.data(2) =  trkTSVQ.tst_rmse;     struct1.data(3) = tsvq_tst_avgrmse(f);        UTIL_savecsv_struct(trkTSVQ.cfn_5_tst_rmse,       f, struct1); end

        %6. RVQ number of stages
        clear struct1;
        if (bUseRVQ)    struct1.data(1) = RVQ.tst_partialP;                                                                                                      UTIL_savecsv_struct(trkRVQ.cfn_6_numStages,    f, struct1); end