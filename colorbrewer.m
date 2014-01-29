function [ cMap ] = colorbrewer( colorName, steps )
%COLORBREWER(colorName, steps) generates a colormap based on select choices from
%	http://colorbrewer2.org
%	Choices include:
%		BuPu, blue - Sequential blue/purple
%		YlOrRd, red - Sequential yellow/orange/red
%		YlGnBu, teal - Sequential yellow/green/blue
%		RdYlBu, redblue - Diverging Red - Yellow - Blue [Default]
%	All colors are colorblind safe
%		
%   Written by: Michael Hutchins

	%% Default parameters
	
	switch nargin
		case 0
			colorName = 'RdYlBu';
			steps = 20;
		case 1
			steps = 20;
	end
	
	%% Select Color
	
	if strcmp(colorName,'BuPu') ||...
			strcmp(colorName,'blue')
		
		rough =	[237,248,251;...
				191,211,230;...
				158,188,218;...
				140,150,198;...
				136,86,167;...
				129,15,124];
					
	elseif strcmp(colorName,'YlOrRd') ||...
			strcmp(colorName,'red')
		
		rough =	[255,255,178;...
				254,217,118;...
				254,178,76;...
				253,141,60;...
				240,59,32;...
				189,0,38];	
				
	elseif strcmp(colorName,'YlGnBu') ||...
			strcmp(colorName,'teal')

		rough =	[255,255,204
				199,233,180;...
				127,205,187;...
				65,182,196;...
				44,127,184;...
				37,52,148];
			
	elseif strcmp(colorName,'RdYlBu') ||...
			strcmp(colorName,'redblue')

		rough =	[215, 48, 39;...
				244, 109, 67;...
				253, 174, 97;...
				254, 224, 144;...
				255, 255, 191;...
				224, 243, 248;...
				171, 217, 233;...
				116, 173, 209;...
				69, 117, 180];
				
	else
		warning('Color not found.  Using default color');		
	end

	
	%% Format output
	
	colorLength = length(rough);
	rough = (rough)./255; % Convert from RGB to matlab 0-1 colorspace
	
	% Interpolate the colorpsace for STEPS
	cMap = interp1([1 : colorLength],rough,linspace(1,colorLength,steps));

end

