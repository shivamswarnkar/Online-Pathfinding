classdef Robot_OPF
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        laser;
        map;
        currPos;
        posTree = {};
    end
    
    methods
        function obj = Robot_OPF(fname, range)
            obj.map = Environment(fname);
            obj.laser = Laser(obj.map, range);
            obj.map.polygons = [];
            obj.currPos = obj.map.start';
            
        end
        
        function obj = scan(obj)
            %obj.posTree{length(obj.posTree)} = obj.currPos;
            obj.map.polygons = [obj.map.polygons obj.laser.scan(obj.currPos)];
            obj.map.start = obj.currPos;
            obj.map.currPos= obj.currPos;
            
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
            a = Robot_OPF(fname, range);
            a.run();
        end
    end    
end

