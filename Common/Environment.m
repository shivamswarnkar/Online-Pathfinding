%{
	Environment class
	
		The environment object defines an instance of the
		path planning problem for a disc robot.
		It needs these data (i.e., properties):
		 
				-- radius of robot
				-- epsilon
				-- bounding box for obstacles
				-- start and goal config of robot
				-- obstacle set (set of polygons)
	
		An environment file (e.g., env0.txt) is a line-based text file
		containing the above information, in THIS STRICT ORDER.
		Comment character (%) indicates that the rest of a line
		are ignored.
	
		Methods:
			env.readFile( fname )
			env.showEnv( fname )
			env.test( fname )
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Intro to Robotics, Spring 2017
	%	Chee Yap (with help of TAs Naman and Rohit)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef Environment < handle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        radius;
        epsilon;
        bBox = [];		% a mapshape (in CW order)
        start = [];		% point = array of size 2
        goal = [];		% point = array of size 2
        polygons = [];		% array of mapshapes (in CCW order)
        currPos;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Environment(fname)
            if nargin<1
                fname = 'env0.txt';
            end
            obj = obj@handle(); % call base class
            
            oo = Environment.readFile(fname);

            % copy:
            obj.radius = oo.radius;
            obj.epsilon = oo.epsilon;
            obj.bBox = oo.bBox;
            obj.start = oo.start;
            obj.currPos = obj.start;
            obj.goal = oo.goal;
            obj.polygons = oo.polygons;
        end
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Robot at conf(a,b) with color c
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showDisc(obj,a,b,c)
            t = linspace(0, 2*pi);
            x = obj.radius*cos(t);
            y = obj.radius*sin(t);
            patch(x+a, y+b, c);

            hold on;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display bBox
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showBBox(obj)
            rectangle('Position',...
                [obj.bBox.X(1)...
                obj.bBox.Y(1)...
                max(obj.bBox.X)...
                max(obj.bBox.Y)],...
                'EdgeColor', 'b', 'LineWidth',3);
            %patch(obj.bBox.X,obj.bBox.Y,'r');

            hold on;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Output Image to file
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function outputFile(obj, fname)
            if nargin<2
                fname = 'image.jpg';
            end
            axis square tight;
            alpha(0.5);	% DOES NOT WORK for screen? OK for image...
            F = getframe(gca);
            imwrite(F.cdata,fname);
            
            % EXPERIMENTAL:
            J = imresize(F.cdata, [256 256]);
            imwrite(J,'image_resized.jpg');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Environment:
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = showEnv(obj, clear, output)
            if nargin < 2
                clear = true;
            end

            if nargin < 3
                output = false;
            end

%             figure(1);

            if clear
                %clf(1);  % clear fig 1 (or else it overlays previous display)
            end

            axis square tight;
            % Show bBox:
            obj.showBBox();
            % show start and goal config:
            bluegreen=[0, 1, 1];
            redgreen=[1, 1, 0];
            obj.showDisc(obj.currPos(1), obj.currPos(2), bluegreen);
            obj.showDisc(obj.goal(1), obj.goal(2), redgreen);
            
            %Display the obstacles in brown:
            brown = [0.8, 0.5, 0];
            for C = obj.polygons
                patch(C{1}.X,C{1}.Y, brown);
            end

            alpha(0.5); % Transparency (to show overlaps)

            hold on;

            % Output an image file:
            if output
                obj.outputFile('image.jpg');
            end
        end

        function obj = showEnvMapshow(obj, output)
            if nargin < 2
                output = false;
            end

            % Perform showEnv using mapshow.
%             figure(2);
            %clf(2); % clear fig 2
            axis square tight;
            % Show Bounding Box:
            obj.showBBox();
            % show start and goal config:
            bluegreen=[0, 1, 1];
            redgreen=[1, 1, 0];
            brown = [0.8, 0.5, 0];  
            obj.showDisc(obj.start(1), obj.start(2), bluegreen);
            obj.showDisc(obj.goal(1), obj.goal(2), redgreen);

            %Display the obstacles in brown using mapshow.

            for C = obj.polygons
                X = C{1}.X;
                Y = C{1}.Y;
                mapshow(X, Y, 'DisplayType', 'polygon', 'FaceColor', brown);
            end

            alpha(0.5); % Transparency (to show overlaps)

            hold on;

            % Output an image file:
            if output
                obj.outputFile('imageMapShow.jpg');
            end
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods(Static)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % readFile( fname )
        %	-- Reads an "env.txt" file with lines in this order:
        %	     radius, eps, bBox, start, goal, polygon*
        %	-- although it returns an "obj", this is only a FAKE
        %		"Environment" object!
        %		The constructor has to copy each component
        %		of this FAKE object into the actual object
        %		begin constructed.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = readFile(filename)
            if nargin < 1
                filename = 'env0.txt';
            end
            fid=fopen(filename);
            nextCase = 1;
            obj.polygons = {};
            numOfPolygons = 0;
            
            numArray = Environment.getNumbers(fid);
            
            while ~ isempty(numArray)
                switch nextCase
                    case 1
                        obj.radius = numArray(1);
                    case 2
                        obj.epsilon = numArray(1);
                    case 3
                        bBoxX = numArray(1:4);
                    case 4
                        bBoxY = numArray(1:4);
                        obj.bBox = mapshape(bBoxX, bBoxY);
                    case 5
                        obj.start = numArray(1:2);
                    case 6
                        obj.goal = numArray(1:2);
                    case 7
                        pBoxX = numArray;
                    case 8
                        pBoxY = numArray;
                        numOfPolygons = numOfPolygons+1;
                        obj.polygons{numOfPolygons} = ...
                            mapshape(pBoxX,pBoxY);
                end % switch
                if nextCase == 8
                    nextCase = 7;
                else
                    nextCase = nextCase+1;
                end
                numArray = Environment.getNumbers(fid);
            end % while
%             for i=1:4
%                 numOfPolygons = numOfPolygons+1;
%                 obj.polygons{numOfPolygons} = mapshape(bBoxX(i), bBoxY(i), 'Geometry','line');
%             end
            if nextCase<7
                disp(['Error reading input file: ', filename]);
                disp(['next Case = ', num2str(nextCase)]);
            end
            fclose(fid);
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % getNumbers( fileID )
        %	returns an array of numbers.
        %	It returns an empty array iff the fileID
        %		has reached EOF.
        % THIS IS A HELPER method for readFile().
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %{
        function numArray = getNumbers(fid)

	       line = fgetl(fid);
	       while ~ isempty(line)
		   % remove comments after '%'
		        loc = strfind(line,'%');
                if(~isempty(loc))
                    line(loc(1):end) = [];
                end
	        % numStrings is an arrays of strings representing numbers:
	            line = regexp(line,'(+|-)?\d+(\.\d+)?','match');
		        numStrings = [];
		        if(~isempty(line))
                    numStrings = regexp(line,'(+|-)?\d+(\.\d+)?','match');
                end

	            numArray = []; % output array
	            for ii= 1:length(numStrings)
	                if ~isempty(numStrings{ii})
	                   numArray(ii) = str2double(numStrings{ii});
	                else
	                   numArray(ii) = NaN;
	                end
	            end
	        end %
        %}
        
        function result = getNumbers(fid)
            line = fgetl(fid); 
            result = []; 
            B = [];
            while ~feof(fid) % ~feof(fid) - for end of file or ischar(line)
                loc = strfind(line,'%');
                if(~isempty(loc))
                    line(loc(1):end) = [];
                end
                if(~isempty(line))
                    B = regexp(line,'(+|-)?\d+(\.\d+)?','match');
                end
                if(~isempty(B))
                    for i= 1:length(B)
                        result(i,1)=str2double(B{i});
                    end
                    break; % come out of while loop
                end
                line = fgetl(fid);
            end % getNumbers
            
        end % properties Static
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % test
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function a = test( filename )
            if nargin<1
                filename = 'env6.txt';
            end
            a = Environment(filename);
            a.showEnv(true); % uncomment this to show the entire environment
            
            % ADDITIONAL TEST: show obstacles using "mapshow" instead of
            %		patch.  How to do color?
            a.showEnvMapshow(true);
        end
    end
end