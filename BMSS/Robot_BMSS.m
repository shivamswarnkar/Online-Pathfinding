classdef Robot_BMSS
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        laser;
        sdiv; %keeps map and other subdiv informations 
        %currPos is kept in env;
        posTree = {};
    end
    
    methods
        function obj = Robot_BMSS(fname, range)
            map = Environment(fname); %initialize current map with env file, but then remove all the obstacles 
            obj.laser = Laser(map, range);
            map.polygons = []; %remove all obstacles, leaving only 
            obj.sdiv = BM_Subdiv2(map, range); %keeps the explored map and other info
            obj.posTree{1} = obj.sdiv.env.start;
        end
        
        %call laser's scan which returns array of new obstalces, add those 
        %new obstacles to our map, and distribute them to leaves 
        function obj = scan(obj)
            %obj.posTree{length(obj.posTree)} = obj.currPos;
            newObstacles = obj.laser.scan(obj.sdiv.env.currPos');
            obj.sdiv.env.polygons = [obj.sdiv.env.polygons newObstacles];
            obj.sdiv.distributeFeatures(newObstacles);
            
        end
    end
    
    methods(Static)
        function a = test(fname, range)
            if(nargin == 1)
                range = 1;
            elseif (nargin < 1)
                fname = 'env0.txt';
                range = 1;
            end
            a = Robot_BMSS(fname, range);
        end
    end    
end

