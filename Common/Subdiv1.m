%{
	file: Subdiv1.m

	Implements a class for Subdiv1 of a rootbox.
		Based on Box1 class.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%`
	Robotics Class, Spring 2017
	Chee Yap (with help of TA's Rohit Muthyla and Naman Kumar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%}

classdef Subdiv1 < handle
    properties
        rootBox;
         colo = [[1 1 1];[0.5 0.5 0.5];[1 0 0]; [1 1 0]; [0 1 0]; [0 0.5 0]];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = Subdiv1(x,y,w)
            obj.rootBox = Box2(x,y,w);
        end
        
        % split(box)
        %	calls Box2.split()
        %
        %   assert(isa(Box2,'Box2'),'Not Box2 object', class(Box2));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function split(~,box)
            box.split();
        end
        
        % findBox(x,y)
        %	returns the leaf box of the current
        %	Subdiv that contains the point (x,y)
        %	If (x,y) lies on the boundary of more than one box,
        %	break ties arbitrarily.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function box = findBox(obj,x,y)
            box = obj.rootBox;
            while(box.isLeaf == 0)
                box = findChild(obj,box,x,y);
            end
        end
        
        % findChild(box,x,y)
        %	does not depend on the Subdiv instance.
        %	Hence the implicit object is specified as "~".
        %	NOTE: the box class has a similar method.
        % assert(isa(Box1,'Box1'),'Not Box1 object', class(Box1));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function childBox = findChild(~,box,x,y)
            if(x < box.x)
                if(y < box.y)
                    childBox = box.child(3);
                else
                    childBox = box.child(2);
                end
            else
                if(y < box.y)
                    childBox = box.child(4);
                else
                    childBox = box.child(1);
                end
            end
        end
        
        
        % showBox(box)
        %	displays the box with index idx
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showBox(~, box)
            box.showBox();
        end
        
        % showLeaves()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showLeaves(obj, box)
            if nargin < 2
                box = obj.rootBox;
            end
            if(box.isLeaf == 1)
                showBox(box);
            else
                for i = 1:length(box.child)
                    obj.showLeaves(box.child(i));
                end
            end
            %{
      sbox = getLeaves(obj, box);
      showBox(sbox);
            %}
        end
        
        function box = getLeaves(obj, box)
            if nargin < 2
                box = obj.rootBox;
            end
            if(box.isLeaf == 1)
                return ;
            else
                for i = 1:length(box.child)
                    obj.getLeaves(box.child(i));
                end
            end
        end
        
        % showSubdiv()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function showSubdiv(obj, box)
            if nargin < 2
                box = obj.rootBox;
            end
            if(box.isLeaf == 1)
                showBox(box);
            else
                for i = 1:length(box.child)
                    obj.showSubdiv(box.child(i));
                end
            end
        end
        
        function displaySubDiv(obj,box)
            
            if nargin < 2
                box = obj.rootBox;
            end
            if(box.isLeaf)
                x1 = box.x - box.w;
                x2 = box.x + box.w;
                y1 = box.y - box.w;
                y2 = box.y + box.w;
                X = [x1, x2, x2, x1, x1];
                Y = [y1, y1, y2, y2, y1];
                
                %fill(box.shape().X,box.shape().Y,obj.colo(int32(box.type),:));
                fill(X, Y, obj.colo(box.type + 4,:));
                plot(X,Y,'b-');
                hold on;
            else
                for i = 1:length(box.child)
                    obj.displaySubDiv(box.child(i));
                end
            end
            xlim([obj.rootBox.x - obj.rootBox.w, obj.rootBox.x + obj.rootBox.w]);
            ylim([obj.rootBox.y - obj.rootBox.w, obj.rootBox.y + obj.rootBox.w]);
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Static = true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function test()
            s = Subdiv1(0,0,1);
            rootBox = s.rootBox;
            %%%%%%%%%%%%%%%%%%%%%% FIRST SPLIT:
            s.split(rootBox);
            
            %%%%%%%%%%%%%%%%%%%%%% SECOND SPLIT:
            box = s.findBox(0.2,-0.7);
            s.split(box);
            %s.showSubdiv();
            %%%%%%%%%%%%%%%%%%%%%% THIRD SPLIT:
            box = s.findBox(0.2,-0.7);
            s.split(box);
            %s.showSubdiv();
            
            box = s.findBox(0.2,-0.7);
            %s.showBox(box);
            s.showLeaves(s.rootBox);
        end
    end
end

