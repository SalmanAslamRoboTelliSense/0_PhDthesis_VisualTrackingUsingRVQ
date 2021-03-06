%> @file UTIL_2D_affine_tllpxy_to_abcdxy.m
%> @brief 
%> 
%> affine1_6x1 : [a      b        c        d     tx   ty]
%> affine2_6x1 : [theta  lambda1  lambda2  phi   tx   ty]
%> 
%> Reference "Multiple View Geometry in Computer Vision" by Richard
%> Hartley and Andrew Zisserman and Jongwoo Lim and David Ross. 
%>
%> Copyright (c) Salman Aslam.  All rights reserved.
%> Date created             :   around Jan 2011
%> Date modified            :   Sep 10, 2011

function abcdxy = UTIL_2D_affine_tllpxy_to_abcdxy(tllpxy) %tllpxy: lambda1, lambda2, theta, phi, tx, ty
    
    %input (read tllpxy)
    theta                   =   tllpxy(1);  
    lambda1                 =   tllpxy(2);  
    lambda2                 =   tllpxy(3);  
    phi                     =   tllpxy(4);
    tx                      =   tllpxy(5);           
    ty                      =   tllpxy(6);               

    %intermediate
    ccc                     =   cos(theta)*(cos(phi))^2;   %can be made quicker by prestoring trigonometric values
    ccs                     =   cos(theta)*cos(phi)*sin(phi);  
    css                     =   cos(theta)*(sin(phi))^2;
    scc                     =   sin(theta)*(cos(phi))^2;  
    scs                     =   sin(theta)*cos(phi)*sin(phi);  
    sss                     =   sin(theta)*(sin(phi))^2;

    m                       =   css - scs;
    n                       =   ccc + scs;
    o                       =   ccs + sss;
    p                       =   ccs - scc;

    %output (create abcdxy)
    a                       =   lambda2*m + lambda1*n;      
    b                       =   lambda2*p - lambda1*o;
    c                       =   lambda2*o - lambda1*p;
    d                       =   lambda2*n + lambda1*m;
    
    abcdxy                =   [a b c d tx ty];