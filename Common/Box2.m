%{
 file: Box2.m
    
    The Box2 class is derived from Box1 class,
        designed to be used by the Subdivision class,
        and for robot motiom planning.
    
    What is new in Box2 class over Box1?
        It has these properties:
            -- outerFeatures (set of corners and edges whose separation
                from the center of box is less than or equal to the 
                radius of the disc robot + the radius/width of the box)
            -- innerFeatures (set of corners and edges whose separation
                from the center of box is less than or equal to the radius
                of the disc robot - the radius/width of the box)
            -- type (FREE/MIXED/STUCK)
            -- principal neighbors (N,S,E,W)
        BUT it cannot set any of these values here!
        This will be done in Subdiv2 that calls Box2.
    
    What is NOT in Box2?
    Information about subdivision tree, such as neighbor properties.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Robotics Class, Spring 2017
    Chee Yap (with help of TA's Rohit Muthyla and Naman Kumar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}
classdef Box2 < Box1
    
    properties
        type = BoxType.UNKOWN;           % = FREE/MIXED/STUCK
        features = {};       
        pNbr = [];      % principal Nbrs - 1, 2, 3, 4 - N, W, S, E
        pNbrOf = [];
        visited = false;    % for Graph Search use later
        pathVisited = false;
        unionFindIdx = -1;
        prev = [];
        next = [];
    end
    
    properties (Constant)
        null = Box2(0,0,0)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Box2(xx, yy, ww, pp)
            if(nargin < 3)
                super_args{1} = 0;
                super_args{2} = 0;
                super_args{3} = 1;
            else
                super_args{1} = xx;
                super_args{2} = yy;
                super_args{3} = ww;
            end
            if(nargin ==4)
                super_args{4} = pp;
            else
                super_args{4} = [];
            end
            obj = obj@Box1(super_args{:});
        end
        
        % The function below is no longer needed as I decide to
        % classify rootbox and their children directly in Subdiv2
        % when they are initialized. 
        
        % Temporarily: randomly classify
        % This should be replaced by real classification later.
        %
        %function classifyRandom(box)
            %random = rand(1);
            %if(random > 0.6)
                %box.type = BoxType.FREE;
            %elseif(random < 0.3)
                %box.type = BoxType.STUCK;
            %else
                %box.type = BoxType.MIXED;
            %end
        %end
        
        %Check if the box is null box        
        function bool = isNull(obj)
            bool = (obj.w==0);
        end
       
        % split()   - Override the function in Box1 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function children = split(obj)
            obj.child = [
                Box2(obj.x+obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
                Box2(obj.x-obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
                Box2(obj.x-obj.w/2,obj.y-obj.w/2,obj.w/2, obj)
                Box2(obj.x+obj.w/2,obj.y-obj.w/2,obj.w/2, obj)];
            obj.isLeaf = false;
            children = obj.child;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static = true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test()
            % Testing some basic functions of box class.
            b = Box2(0,0,1);
            b.showBox();
            disp(['-->> Is root a leaf? ',num2str(b.isLeaf)]);
            children = b.split();
            disp('-->> child 1 = '); children(1).showBox();
            disp('-->> child 2 = '); children(2).showBox();
            disp('-->> child 3 = '); children(3).showBox();
            disp(['-->> Is root a leaf? ',num2str(b.isLeaf)]);
            disp(['-->> Is child(1) a leaf? ',num2str(children(1).isLeaf)]);
            disp(['-->> Which child contains (-0.2, 0.6)  ? ', ...
                num2str(b.findQuad(-.2,.6))]);
            disp(['-->> Is (0.5, -2) inside box(0,0,1)? ', ...
                num2str(b.isIn(0.5,-2))]);
            %
            %       corner = children(4).SW;
            %       disp(['-->> SW corner of child(4) = (', ...
            %           num2str(corner(1)), ', ', num2str(corner(2)), ')']);
        end
    end
end