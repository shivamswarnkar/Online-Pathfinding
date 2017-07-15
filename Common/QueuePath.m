%Same class as Queue, just checks for different visited point
%due to lack of time, we didn't merge both classes
%Constructor q = QueuePath(goal);
%q.push(box); q.pop() -> box; q.isEmpty() -> bool; 
%q.add(lst of box);
%q.disp() -> prints all the values in the q (x, y) format
classdef QueuePath < handle

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		lst = [Box2(0,0,-1)];
        goal = [];
        epsilon;
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Constructor
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function q = QueuePath(goal, epsilon)
	    	q.goal = transpose(goal);
            q.lst(1) = [];
            q.epsilon = epsilon;
        end
        
        %add a box to queue
        function push(obj, value)
            if(value.pathVisited)
                return;
            end
            if length(obj.lst) < 1
                obj.lst= value;
            
            elseif obj.equal(value, obj.lst(1))
                return;
            elseif obj.comp(value, obj.lst(1))
                obj.lst = [value obj.lst];
                return;
            else
                for i=2:length(obj.lst)
                    if(obj.equal(value, obj.lst(i)))
                        return;
                    elseif obj.comp(value, obj.lst(i))
                        obj.lst = [obj.lst(1:i-1) value obj.lst(i:end)];
                        return;
                    end
                end
                
                obj.lst = [obj.lst value];
            end
        end
        
        %add array of boxes to the  
        function add(obj, list)
            for i = 1:length(list)
                %disp(list(i));
                obj.push(list(i));
            end
        end
        
        %checks if q is empty
        function flag = isEmpty(obj)
            flag = isempty(obj.lst);
        end
        %returns length
        function l = length(obj)
            l = length(obj.lst);
        end
        %remove all items
        function clear(obj)
            obj.lst = [];
        end
        %pop the nearest box to the goal
        function val = pop(obj)
            if(length(obj.lst)<1)
                return;
            end
            val = obj.lst(1);
            obj.lst(1) = [];
        end
        
        %compare two boxes and return true if first box is closer to goal
        function flag = comp(obj,a,b)
            %disp(obj.goal);
            %disp([a.x a.y]);
            flag = Geom2d.sep([a.x a.y], obj.goal) <= Geom2d.sep([b.x b.y], obj.goal);
        end
        
       
        %display all the boxes as x y center cordinates values
        function disp(obj)
            for i=1:length(obj.lst)
                disp(['(x: ', num2str(obj.lst(i).x),', y:', num2str(obj.lst(i).y), ')']);
            end
        end
        end
   
  
    
    

	    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         function flag = equal(box1, box2)
            flag = ((box1.x == box2.x) && (box1.y == box2.y) && (box1.w == box2.w));
        end
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % test()
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = test()
            q = Queue([0;0], 0.1);
            q.push(Box2(2,4,1));
            q.push(Box2(9,9,10));
            q.push(Box2(9,9,10));
            %q.disp();
            q.push(Box2(2,5,1));
            q.push(Box2(3,7,1));
            q.push(Box2(1,4,1));
            disp('----');
            q.disp();
            q.push(Box2(1,4,1));
            disp('----');
            q.disp();
            q.add([Box2(1,4,1) Box2(1,4,1) Box2(2,5,1) Box2(2,7,1)  ]);
            disp('----');
            q.disp();
            q.pop();
            disp('poped one item');
           
            q.disp();
            flag =1;
            
	    end

	end


end % Queue class

