%{
	SSS class:
		this is the main class encoding the
		"Soft Subdivision Search" technique.

	The Main Method:
		Setup Environment
			(read from file and initialize data structures)
%}

classdef SSS < handle

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		fname;		% filename
		sdiv;		% subdivision
		path=[];	% path 
        animationPath = [];
		startBox=[];	% box containing the start config
		goalBox=[];	% box containing the goal config
        queue = [];
        t=0;
        mainloopRan = false;
        isQuit;
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Constructor
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function sss = SSS(env)
	    	if (nargin < 1)
                env = Environment('env0.txt');
            end
		sss.setup(env);
        sss.startBox = [];
        sss.goalBox = [];
        sss.isQuit = false;
%         sss.t=0;
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % run (arg)
	    %		if no arg, run default example
	    %		if with arg, do
	    %			interactive loop (ignores arg)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function run(obj, arg)
	    	if nargin<1
                flag = obj.mainLoop();
                if(flag)
                obj.showPathAnimation();
                end
                return;
            end

		disp('Welcome to SSS!');
	    while true
            option = input(['Choose an options:', '0=quit, 1=mainLoop, 2=showEnv, 3=showPath','4=new setup ', '5=subdivision', '6=show path animation ']);
	        switch option
                case 0,
                    return;
                case 1,
                    flag = obj.mainLoop();
                    if(flag)
                    obj.showPathAnimation();
                    end
                case 2,
                    obj.showEnv();
                case 3,
                    obj.showPath();
                case 4,
                    obj.fname=input('input environment file: ');
                    obj.setup(obj.fname);
                    obj.showEnv();
                case 5,
                    obj.sdiv.displaySubDiv();
                    
                case 6,
                    obj.showPathAnimation();
                otherwise
                    disp('invalid option');
	         end % switch
        end % while
        end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % mainLoop
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = mainLoop(obj)
            obj.mainloopRan = true;

	        flag = [];
            startConfig = obj.sdiv.env.start;
            goalConfig = obj.sdiv.env.goal;
	    	obj.startBox = obj.makeFree(startConfig);
		if isempty(obj.startBox)
		    disp('NOPATH: start is not free');
		    return;
        end
        %disp('Found start box');

	    	obj.goalBox = obj.makeFree(goalConfig);
		if isempty(obj.goalBox)
		    disp('NOPATH: goal is not free');
		    return;
        end
        %disp('Found goal box');
        
        if (~obj.makeConnected())
		    display('NOPATH: start and goal not connected');
		    return;
        end
        %obj.sdiv.displaySubDiv();
        %drawnow;
        %obj.sdiv.env.showEnv(false);
        %drawnow;
        obj.showPath();
        %drawnow;
        %pause(2);
		flag = obj.path;
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % Setup
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function setup(obj, env)
	    	obj.sdiv = Subdiv2(env);
            obj.mainloopRan = false;
            %obj.unionF = UnionFind();
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeFree(config)
	    %		keeps splitting until we find
	    %		a FREE box containing the config.
	    %		If we fail, we return [] (empty array)
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function box = makeFree(obj, config)
            box = obj.sdiv.findBox(config(1), config(2));
            while box.type ~= BoxType.FREE && box.w > obj.sdiv.env.epsilon
                %disp(box.type);
                obj.sdiv.split(box);
                box = obj.sdiv.findBox(config(1), config(2));
            end
            if box.type ~= BoxType.FREE  
                box = [];
            end
	    end


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % makeConnected(startBox, goalBox)
	    %		keeps splitting until we find
	    %		a FREE path from startBox to goalBox.
	    %		Returns true if path found, else false.
        % we are get all nbrs, push them on the priority queue
        % and then select the box closest to the goal, and explore
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = makeConnected(obj)
            
%            find(obj, x)
            q = PriorityQueue([obj.goalBox.x; obj.goalBox.y],obj.sdiv.env.epsilon );
            nbrs = obj.sdiv.getNeighbours(obj.startBox);
            obj.startBox.visited = true;
            obj.sdiv.setPrev(nbrs, obj.startBox);
            %disp(nbrs(1));
            q.add(nbrs);
            
            box = q.pop();
            cont = true;
            disp('working...');
            
            t=0;
            while ((~q.isEmpty()|| box.type == BoxType.MIXED) && ~(obj.sdiv.unionF.find(obj.goalBox) == obj.sdiv.unionF.find(obj.startBox)))%box.isIn(obj.sdiv.env.goal(1),obj.sdiv.env.goal(2) ) && box.type==BoxType.FREE))
                %t = t+1;
                
                
                %for nbr = nbrs
                   %nbr.showBox();
                %end
                box.visited = true;
                if box.type == BoxType.FREE
                    %box.unionFindIdx = obj.sdiv.unionF.add(box);
                    box.prev.next = box;
                    nbrs = obj.sdiv.getNeighbours(box);
                    obj.sdiv.setPrev(nbrs, box);
                    q.add(nbrs); %
                   
                elseif box.type == BoxType.MIXED
                    obj.sdiv.split(box);
                    %add children sharing edge with parent
                    nbrs = obj.sdiv.getNeighbours(box.prev);
                    for nbr = nbrs
                        %nbr.showBox();
                        if(nbr.w ~=0 && q.equal(nbr.parent,box))
                            nbr.prev = box.prev;
                            q.push(nbr);
                        end
                    end
                    
                end
                box = q.pop();
                
                    
               
            end
            if(obj.sdiv.unionF.find(obj.goalBox) == obj.sdiv.unionF.find(obj.startBox))
                flag = true;
                %obj.goalBox = box;
                
            else
                flag = false;
            end
            if(flag)
                %disp('here');
                box.next = obj.goalBox;
                %obj.goalBox.prev.next = obj.goalBox;
            end
            
        end
        
        %using the almost the same queue class, we're building the path by
        %exploring closest box to the goal
        function flag = findPath(obj, currBox)
            if(QueuePath.equal(currBox, obj.goalBox))
                flag = true;
                return;
            end
            currBox.pathVisited = true;
            q = QueuePath([obj.goalBox.x; obj.goalBox.y],obj.sdiv.env.epsilon);
            for nbr = obj.sdiv.getNeighbours(currBox)
                % disp(obj.goalBox.unionFindIdx);
                 if(nbr.type ~= BoxType.FREE || nbr.unionFindIdx == -1)
                     continue;
                 end
                 if(~nbr.pathVisited  && (obj.sdiv.unionF.find(obj.goalBox) == obj.sdiv.unionF.find(nbr)))
                    %disp(num2str(nbr.unionFindIdx));
                     
                    q.push(nbr);
                 end
            end
                
            
            found = false;
            while(~q.isEmpty() && ~found)
                nbr = q.pop();
                nbr.prev = currBox;
                found = findPath(obj, nbr);
            end
            if(found)
                currBox.next = nbr;
                flag = true;
            else
                flag=false;
            end
        end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showPath(path)
	    %		Animation of the path
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showPath(obj)
            if(~obj.mainloopRan)
                obj.mainLoop();
            end
            
            obj.findPath(obj.startBox);
            currBox = obj.startBox;
            %plot([obj.sdiv.env.start(1), obj.startBox.x],[obj.sdiv.env.start(2), obj.startBox.y],'-.or');
            %hold on;
            obj.path=[];
            
            while ~PriorityQueue.equal(currBox, obj.goalBox)
                %currBox.showBox();
                obj.path{length(obj.path)+1} = [currBox.x currBox.y];
                obj.animationPath{length(obj.animationPath)+1} = [[currBox.x  currBox.next.x], [currBox.y currBox.next.y]];
                %plot([obj.animationPath{length(obj.animationPath)}(1) obj.animationPath{length(obj.animationPath)}(2)], [obj.animationPath{length(obj.animationPath)}(3) obj.animationPath{length(obj.animationPath)}(4)],'-.or');
                %hold on
                currBox = currBox.next;
                
            end
            obj.path{length(obj.path)+1} = [currBox.x currBox.y];
            obj.path{length(obj.path)+1} = [obj.sdiv.env.goal(1) obj.sdiv.env.goal(2)];
            
            plot([obj.sdiv.env.goal(1), obj.goalBox.x],[obj.sdiv.env.goal(2), obj.goalBox.y],'-.or');
            %hold off
            %obj.sdiv.env.showEnv(false);
            
        end
        
        
        function showPathAnimation(obj)
            if(~obj.mainloopRan)
                obj.mainLoop();
            end
            obj.findPath(obj.startBox);
            currBox = obj.startBox;
            obj.path=[];
            
            while ~PriorityQueue.equal(currBox, obj.goalBox)
                %currBox.showBox();
                currBox = currBox.next;
                obj.sdiv.env.showEnv(true);
                obj.sdiv.env.showDisc(currBox.x,currBox.y,[0, 1, 1]);
                drawnow;
                pause(0.1);
               
                
            end
            obj.sdiv.env.showEnv(true);
            obj.sdiv.env.showDisc(obj.sdiv.env.goal(1),obj.sdiv.env.goal(2),[0, 1, 1]);
            drawnow;
            
            
	    end

	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % showEnv()
	    %		Display the environment
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function showEnv(obj)
            obj.sdiv.env.showEnv();
	    end

	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static = true)
        
        %to test if given array contains the elements
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    


	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    % test()
	    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	    function flag = test(fname)
            if nargin<1
                fname = 'env0.txt';
            end
            s = SSS(fname);
            s.run(); 
	    end

	end


end % SSS class

