                                TRK_draw_4a_recon_reconerr(trkIPCA.recon,  trkIPCA.err_0to1_shxsw, PARAM.plot_num_rows,  PARAM.plot_num_cols,   PARAM.plot_row2, PARAM.plot_row3,   PARAM.plot_title_fontsz, 1);  %notice the minus
   if (bUseBPCA )                TRK_draw_4a_recon_reconerr(trkBPCA.recon,  trkBPCA.err_0to1_shxsw, PARAM.plot_num_rows,  PARAM.plot_num_cols,   PARAM.plot_row2, PARAM.plot_row3,   PARAM.plot_title_fontsz, 2); end
   if (bUseRVQE)                 TRK_draw_4a_recon_reconerr(trkRVQE.recon,  trkRVQE.err_0to1_shxsw, PARAM.plot_num_rows,  PARAM.plot_num_cols,   PARAM.plot_row2, PARAM.plot_row3,   PARAM.plot_title_fontsz, 3); end
   if (bUseTSVQ)                TRK_draw_4a_recon_reconerr(trkTSVQ.recon,  trkTSVQ.err_0to1_shxsw, PARAM.plot_num_rows,  PARAM.plot_num_cols,   PARAM.plot_row2, PARAM.plot_row3,   PARAM.plot_title_fontsz, 4); end
