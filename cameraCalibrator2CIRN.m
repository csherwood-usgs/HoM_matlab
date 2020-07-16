%% cameraCalibrator2CIRN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This function converts the intrinsics calcuated from the caltech toolbox
%  to nomenclature congruent with the CRIN architecture. 


%  Input:
%  camcalibratorpath = filepath of saved calibration results from Matlab's
%  Camera Calibrator... Assumes that you saved the variable as "params"

%  Output:
%  intrinsics = 11x1 Vector of intrinsics

%  Required CIRN Functions:
%  None

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [intrinsics] =cameraCalibrator2CIRN(caltechpath)

%% Load Function
load(caltechpath)
  % Assumes variables are stored in structure called "params"!
%% Conversion
intrinsics(1) = params.ImageSize(2);            % Number of pixel columns
intrinsics(2) = params.ImageSize(1);            % Number of pixel rows
intrinsics(3) = params.PrincipalPoint(1);         % U component of principal point  
intrinsics(4) = params.PrincipalPoint(2);          % V component of principal point
intrinsics(5) = params.FocalLength(1);         % U components of focal lengths (in pixels)
intrinsics(6) = params.FocalLength(2);         % V components of focal lengths (in pixels)
intrinsics(7) = params.RadialDistortion(1);         % Radial distortion coefficient
intrinsics(8) = params.RadialDistortion(2);         % Radial distortion coefficient
intrinsics(9) = params.RadialDistortion(3);         % Radial distortion coefficient
intrinsics(10) = params.TangentialDistortion(1);        % Tangential distortion coefficients
intrinsics(11) = params.TangentialDistortion(2);        % Tangential distortion coefficients




