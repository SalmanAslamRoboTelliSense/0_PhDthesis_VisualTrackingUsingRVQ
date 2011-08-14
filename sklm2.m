%> @file sklm.m 
%> @brief This file computes incremental SVD (Sequential Karhunen-Loeve Transform)
%>
%> A is old data matrix
%> B is new data matrix
%> C                                =   [A B];
%> [Utilde, Stilde, meanC_Dx1, n]   =   sklm(B_DxM, U_DxN1, S_N1x1, meanA_Dx1, M, ff)
%> [Utilde, Stilde, meanC_Dx1, n]   =   sklm(B_DxM, U_DxN1, S_N1x1, meanA_Dx1, M, ff, K)
%>                                      sklm(B_DxM)  %> initialize
%>
%> without meanA_Dx1 or meanC_Dx1, B_DxM is assumed as zero-mean
%>
%> wmd                      : weighted mean diff
%> required input
%> --------------
%> B_DxM (D,n)              : initial/additional B_DxM
%> U_DxN1 (D,N)             : old basis
%> S_N1x1 (N,1)             : old singular values
%>
%> optional input
%> --------------
%> meanA_Dx1 (D,1)            : old mean
%> M                        : number of previous B_DxM
%> ff                       : forgetting factor (def=1.0)
%> K                        : maximeanm number of basis vectors to retain
%>
%> output
%> ------
%> Utilde (D,N+n)           : new basis
%> Stilde (N+n,1)           : new singular values
%> meanC_Dx1 (D,1)          : new mean
%> n                        : new number of B_DxM
%>
%> based on
%> --------
%> A. Levy & M. Lindenbaum 
%> "Sequential Karhunen-Loeve Basis Extraction and its Application to Image", 
%> IEEE Trans. on Image Processing Vol. 9, No. 8, August 2000.
%>
%> All changes by Salman Aslam are cosmetic, name changes, etc,
%> functionality intact.
%>
%> Copyright (C) 2005 Jongwoo Lim and David Ross.  All rights reserved.  (Changed with permission by Salman Aslam) 
%> Date created:  March 19, 2011
%> Date modified: Aug 13, 201



function [Utilde, Stilde, meanC_Dx1, n] = sklm2(B_DxM, U_DxN1, S_N1x1, meanA_Dx1, M, ff, K)

%-----------------------------------------------
%PRE-PROCESSING
%----------------------------------------------
    [D,n]                   =   size(B_DxM);

%-----------------------------------------------
%PROCESSING
%-----------------------------------------------
  
    %part 1. user has input almost nothing
    if (nargin == 1) || isempty(U_DxN1)
        if (size(B_DxM,2) == 1)
            meanC_Dx1       =   reshape(B_DxM(:), size(meanA_Dx1));
            Utilde          =   zeros(size(B_DxM)); 
            Utilde(1)       =   1; 
            Stilde          =   0;
        else
            meanC_Dx1       =   mean(B_DxM,2);
            B_mr_DxM        =   B_DxM - repmat(meanC_Dx1,[1,n]);
            [Utilde,Stilde,Vtilde]   ...
                            =   svd(B_mr_DxM, 0);
            Stilde          =   diag(Stilde);
            meanC_Dx1       =   reshape(meanC_Dx1, size(meanA_Dx1));
        end
        if nargin >= 7
            keep            =   1:min(K,length(Stilde));
            Stilde          =   Stilde(keep);
            Utilde          =   Utilde(:,keep);
        end
    
        
    %part 2. user has input quite a bit    
    else
        if (nargin < 6)  ff = 1.0;  end
        
        if (nargin < 5)  M  = n;    end
        
        if (nargin >= 4 & isempty(meanA_Dx1) == false)
            
            %step 1. compute mean of C=[A B]
            meanB_Dx1       =   mean(B_DxM,2);                              %new data
            newM            =   ff*M;
            meanC_Dx1       =  (newM*meanA_Dx1 + n*meanB_Dx1)/(n+newM);     %combined data
            
            %step 2. augment mean removed B with wmd (weighted mean difference)
            B_mr_DxM        =   B_DxM - repmat(meanB_Dx1,[1,n]);            %mean removed B  
            w               =   sqrt(n*M/(n+M));
            wmd_old_new     =   w*(meanA_Dx1 - meanB_Dx1);                  %wmd is weighted mean difference
            B_hat_DxMp1     =   [B_mr_DxM      wmd_old_new];     
            
            n               =   n+newM;
        end
        Stilde              =   diag(S_N1x1);
        %>[new_basis,R,E]           =   qr([ ff*U_DxN1*Stilde, B_hat_DxMp1 ], 0); %> old way

		%step 3.
        Bproj_MxNp1         =   U_DxN1'*B_hat_DxMp1;            %> projections on U
        Bin_DxNp1           =   U_DxN1*Bproj_MxNp1;
        Bout_DxNp1          =   B_hat_DxMp1 - Bin_DxNp1;
        [Btilde_DxNp1, dummy] ...
                            =   qr(Bout_DxNp1, 0);
        new_basis           =   [U_DxN1 Btilde_DxNp1];                      %spans A (old) and B (new)
        R                   =   [ff*diag(S_N1x1)                               Bproj_MxNp1; ...
                                 zeros([size(B_hat_DxMp1,2) length(S_N1x1)])   Btilde_DxNp1'*Bout_DxNp1];
	
		%step 4.
        [Utilde,Stilde,Vtilde]  ...
                            =   svd(R, 0);
        
		%step 5.
		Stilde              =   diag(Stilde);
        if nargin < 7
            cutoff          =   sum(Stilde.^2) * 1e-6;
            keep            =   find(Stilde.^2 >= cutoff);
        else
            keep            =   1:min(K,length(Stilde));
        end
        Stilde              =   Stilde(keep);
        Utilde              =   new_basis * Utilde(:, keep);
    end

%-----------------------------------------------
%POST-PROCESSING
%-----------------------------------------------