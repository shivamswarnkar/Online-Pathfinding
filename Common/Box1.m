%{
 file: Box1.m
	
 	The Box1 class is designed to be called by the Subdivision class.
	
	NOTE:	One reason for the name "Box1" is that "Box" is defined
		by Maple, and it sometimes cause confusion.

	Each box is a square defined by three independent parameters:
		x, y, w
	where (x,y) is the box center, and w the half-width.

	We have dependent properties like
		NEcorner, SEcorner, SWcorner, NWcorner
	for the four corners of the box.

	In Subdivision class, the boxes must be treated as objects
		because it has state information.
		So that our boxes are "handle objects".
	
	What is NOT implemented in Box1.m are information related to
	the subdivision tree, such as the neighbor properties.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Robotics Class, Spring 2017
	Chee Yap (with help of TA's Rohit Muthyla and Naman Kumar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef Box1 < handle
    properties
        x; y; w;
        parent;
        isLeaf = true;
        child = []; % We assume the four children are indexed so that
        % the i-th child is in the i-th quadrant (i=1,2,3,4)
    end
        
    properties (Dependent)
        NEcorner; SEcorner; SWcorner; NWcorner;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Constructor:
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Box1(xx, yy, ww, pp)
            if(nargin == 3)
                obj.x = xx;
                obj.y = yy;
                obj.w = ww;
            elseif (nargin == 4)
                obj.x = xx;
                obj.y = yy;
                obj.w = ww;
                obj.parent = pp;
            else
                error('Wrong number of input args');
            end
        end
        
        % NEcorner: dependent value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corner = get.NEcorner(obj)
            corner = [ obj.x + obj.w, obj.y + obj.w];
        end
        
        % SWcorner: dependent value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corner = get.SWcorner(obj)
            corner = [ obj.x - obj.w, obj.y - obj.w];
        end
        
        % NWcorner: dependent value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corner = get.NWcorner(obj)
            corner = [ obj.x - obj.w, obj.y + obj.w];
        end
        
        % SEcorner: dependent value
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function corner = get.SEcorner(obj)
            corner = [ obj.x + obj.w, obj.y - obj.w];
        end
        
        function s = shape(obj)
            mx = obj.x;
            my = obj.y;
            ww = obj.w;
            s = mapshape([mx-ww, mx+ww, mx+ww, mx-ww],...
                [my-ww, my-ww, my+ww, my+ww]);
        end
        
        % split()
        %	returns an array of four children
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function children = split(obj)
            obj.child = [
                Box1(obj.x+obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
                Box1(obj.x-obj.w/2,obj.y+obj.w/2,obj.w/2, obj)
                Box1(obj.x-obj.w/2,obj.y-obj.w/2,obj.w/2, obj)
                Box1(obj.x+obj.w/2,obj.y-obj.w/2,obj.w/2, obj)];
            obj.isLeaf = false;
            children = obj.child;
        end

        % isIn(x,y) returns true if (x,y) is inside the box.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function inside = isIn(obj, x, y)
            ww = obj.w;
            xx = obj.x;
            yy = obj.y;
            inside = false;
            if (x>= (xx - ww) && x<= (xx + ww) && ...
                    y>= (yy - ww) && y<= (yy + ww))
                inside = true;
            end
        end
        
        %returns true if the box is a leaf
        function leaf = IsLeaf(obj)
            leaf = obj.isLeaf;
        end
        
        % findQuad(x,y) returns index i if (x,y) is in quadrant i
        %   	for some i = 1,2,3,4.
        %   	ASSERT: (x,y) lies within the box.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function quad = findQuad(obj, x, y)
            if (x>obj.x)
                if (y>obj.y)
                    quad = 1;
                else
                    quad = 4;
                end
            else
                if (y>obj.y)
                    quad = 2;
                else
                    quad = 3;
                end
            end
        end
        
        % showBox() is displays some information about the box.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showBox(obj)
            if (obj.isLeaf == 1)
                disp(['leaf box(', num2str(obj.x), ', ', ...
                    num2str(obj.y), ', ', num2str(obj.w), ')']);
            else
                disp(['internal box(', num2str(obj.x), ', '  ...
                    ,num2str(obj.y), ', ', num2str(obj.w), ')']);
            end;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static = true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Testing some basic functions of box class.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test()
            b = Box1(0,0,1);
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
            disp(['-->> Is (0.5, -2) inside Box1(0,0,1)? ', ...
                num2str(b.isIn(0.5,-2))]);
        end
    end
end