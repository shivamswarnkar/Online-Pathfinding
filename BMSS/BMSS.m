classdef BMSS < handle
    %This class implements the Bounded Modified Subdivision Search (BMSS).
    %It contains following properties
    %Propert : robot, subdiv;
    %Methods : 
    %static test : 
    
    properties
        robot; %Robot
       % subdiv; %Subdiv2
       
        gui;
        isQuit;
        showSubdiv;
        showLaser;
        showPath;
        
        latency;
        time;
        boxVisited;
        goalSep;
    end
    
    methods
        function obj = BMSS(gui, fname, range)
            obj.robot = Robot_BMSS(fname, range);
            obj.gui = gui;
        
            obj.isQuit = false;
            obj.showSubdiv = false;
            obj.showLaser = false;
            obj.showPath = false;

            obj.latency = 0;
            obj.time = 0;
            obj.boxVisited = 0;
            obj.goalSep = Geom2d.sep([obj.robot.sdiv.env.goal(1) obj.robot.sdiv.env.goal(2)],...
                [obj.robot.sdiv.env.start(1) obj.robot.sdiv.env.start(2)]);
        end
        
      
        %RUNS THE MAIN ALGORITHM
        function flag = findGoal(obj)
            tic;
            numBox = 0;
            flag = false;
            obj.robot.sdiv.env.showEnv();
            axis manual;
            startBox = obj.makeStartFree();
            if(startBox == [])
                disp('NO PATH: START NOT FREE');
                return;
            end
            nbrs = obj.robot.sdiv.getNeighbours(startBox);
            obj.robot.sdiv.setPrev(nbrs, startBox);
            q = PriorityQueue(obj.robot.sdiv.env.goal, obj.robot.sdiv.env.epsilon);
            q.add(nbrs);
            startBox.visited = true;
            currBox =startBox;
            
            while ( ~obj.isQuit && ~(currBox.isIn(obj.robot.sdiv.env.goal(1), obj.robot.sdiv.env.goal(2)) && currBox.type == BoxType.FREE) &&...
                    (~q.isEmpty() ))
                numBox = numBox +1;
                currBox =q.pop();
                currBox.visited = true;
               
                if currBox.type == BoxType.FREE
                    obj.robot.sdiv.env.currPos = [currBox.x currBox.y]';
                    obj.robot.posTree = [obj.robot.posTree obj.robot.sdiv.env.currPos];
                    obj.robot.scan();
                    nbrs = obj.robot.sdiv.getNeighbours(currBox);
                    obj.robot.sdiv.setPrev(nbrs, currBox);
                    q.add(nbrs);   
                else
                    obj.robot.sdiv.split(currBox);
                    currBox.prev.visited = false;
                    q.push(currBox.prev);
    
                end
                cla;
                if(obj.showSubdiv)
                    obj.robot.sdiv.displaySubDiv();
                    drawnow;
                end
                axis manual;
                obj.robot.sdiv.env.showEnv();
                drawnow;
                
                
                if(obj.showLaser)
                    axis manual;
                    viscircles(obj.robot.sdiv.env.currPos', obj.robot.laser.range, 'LineStyle','--');
                    drawnow;
                end
                
                if(obj.showPath)
                    obj.displayCurrPath();
                    drawnow;
                end
                
                pause(obj.latency);
                set(obj.gui.time, 'String', num2str(toc));
                set(obj.gui.box_visited, 'String', num2str(numBox));
                
                
            end
            if(currBox.isIn(obj.robot.sdiv.env.goal(1), obj.robot.sdiv.env.goal(2)) && currBox.type == BoxType.FREE)
                flag = true;
                obj.robot.sdiv.env.currPos = obj.robot.sdiv.env.goal;
            end
        end
        
        function box = makeStartFree(obj)
            obj.robot.scan();
            if(obj.showLaser)
                    axis manual;
                    viscircles(obj.robot.sdiv.env.currPos, obj.robot.laser.range, 'LineStyle','--');
                    drawnow;
            end
            box = obj.robot.sdiv.findBox(obj.robot.sdiv.env.start(1), obj.robot.sdiv.env.start(2));
            while box.type ~= BoxType.FREE && box.w > obj.robot.sdiv.env.epsilon
                obj.robot.sdiv.split(box);
                box = obj.robot.sdiv.findBox(obj.robot.sdiv.env.start(1), obj.robot.sdiv.env.start(2));
            end
            if box.type ~= BoxType.FREE || ~box.isIn(obj.robot.sdiv.env.start(1), obj.robot.sdiv.env.start(2))
                box = [];
            end
            
        end
        
        function displayCurrPath(obj)
            %access obj.robot.posTree
            axis manual;
            for i=1 : length(obj.robot.posTree)-1
                plot([obj.robot.posTree{i}(1) obj.robot.posTree{i+1}(1)], [obj.robot.posTree{i}(2) obj.robot.posTree{i+1}(2)],'-.or');
                hold on
            end
            
            
            %plot([obj.robot.posTree{i}(1) obj.robot.posTree{i+1}(1)], [obj.robot.posTree{i}(2) obj.robot.posTree{i+1}(2)],'-.or');
            hold off
        end
        function displayEnv(obj)
            axis manual;
            obj.robot.sdiv.env.showEnv();
        end
        function displaySubDiv(obj)
            obj.robot.sdiv.displaySubDiv();
        end
    end
    
    methods(Static)
%         function a = test(fname, range)
%             if(nargin == 1)
%                 range = 5;
%             elseif (nargin < 1)
%                 fname = 'env1.txt';
%                 range = 10;
%             end
%             a = BMSS(fname, range);
% %           box = a.makeStartFree();
%             %box.showBox();
%             flag = a.findGoal();
%             if(flag)
%                 a.showPath();
%             end
%             a.robot.sdiv.displaySubDiv();
%             a.robot.sdiv.env.showEnv(false);
%             drawnow;
% 
%         end
    end
    
end

