function [ storm, tree ] = cluster_entln( data, varargin)
%CLUSTER_ENTLN takes in normally formatted ENTLN data returns a vector of
%	storm ID numbers for each stroke. Storm 0 strokes are ungrouped.
%
%	Created by: Michael Hutchins

	%% clusters Parameters

		eps = .12; % Degrees
		minPts = 2; % Points
		epsTime = 900; % Seconds
		windowSize = 0.25;
		centerSize = 0.25;
		
	%% Check for override parameters

	for i = 1 : length(varargin)
	
		input = varargin{i};
		
		if ischar(input)

			switch varargin{i}
				case 'eps'
					eps = varargin{i+1};
				case 'minPts'
					minPts = varargin{i+1};
				case 'epsTime'
					epsTime = varargin{i+1};
				case 'windowSize'
					windowSize = varargin{i + 1};
				case 'centerSize'
					centerSize = varargin{i + 1};					
			end
		end
	end
			
	%% Convert time to distance
	
		timeScale = epsTime / eps;
	
		seconds = datenum(data(:,1:6));
		seconds = seconds - min(seconds);
		seconds = seconds * 24*3600;
		seconds = seconds./timeScale;

	%% Format data
		D = [data(:,7),data(:,8), seconds];

		hours = data(:,4) + data(:,5)./60;

	%% Set final storage array

		tree = zeros(size(D,1),50);
		clusters = zeros(size(D,1),1);
			
	%% Go through each time window
		
		windowIndex = 1;
	
		for j = 0 : windowSize : 24 - centerSize


			window = hours >= j - windowSize &...
					 hours <= j + centerSize + windowSize;

			center = hours >= j &...
					 hours <= j + centerSize;


			clusterHours = hours(window);

			clusterCenter =  clusterHours >= j &...
							 clusterHours <= j + centerSize;

			cluster = dbscan(D(window,:), eps, minPts);


			clusterOffset = cluster + max(tree(:)) + 1;
			clusterOffset(cluster == 0) = 0;			

			clusters(center) = clusterOffset(clusterCenter);
			tree(window,windowIndex) = clusterOffset;
			windowIndex = windowIndex + 1;
		end
	
	%% Traverse tree and combine each window results
	
		clusters = tree_traversal(tree);
		
	%% Renumber clusters
	
		cluster = clusters(:);

		storm = zeros(length(cluster),1);
		
		stormID = unique(cluster);
		stormIndex = 1;
		
		for i = 1 : length(stormID);
			
			storm(cluster == stormID(i)) = stormIndex;
			stormIndex = stormIndex + 1;
			
		end
		
		storm(cluster == 0) = 0;
	
end

