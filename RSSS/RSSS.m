classdef RSSS < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        robot;
        sss;
        gui;
        
        showSubdiv;
        showLaser;
        showPath;
        
        latency;
        time;
        boxVisited;
        goalSep;
        isQuit;
       
    end
    
    methods
        function obj = RSSS(gui,fname, range)
            obj.gui = gui;
            obj.robot = Robot_OPF(fname, range);
            
            obj.isQuit = false;
            obj.showSubdiv = false;
            obj.showLaser = false;
            obj.showPath = false;

            obj.latency = 0;
            obj.time = 0;
            obj.boxVisited = 0;
            obj.goalSep = Geom2d.sep([obj.robot.map.goal(1) obj.robot.map.goal(2)],...
                [obj.robot.map.start(1) obj.robot.map.start(2)]);
        end
        
        function run(obj)
            tic
            bestPos = [-1 -1];
            prevPos = [-1 -1];
            prevBox = [-1 -1];
            cla;
            obj.robot.map.showEnv();
            numBox = 0;
            while ~obj.isQuit & (bestPos ~= transpose(obj.robot.map.goal))
                numBox = numBox +1;
                obj.robot.scan();
                obj.sss = SSS(obj.robot.map);
                path = obj.sss.mainLoop();
                if(isempty(path))
                    disp('NO PATH AVAILABLE');
                    return;
                end
                prevPos = bestPos;
                for pos = path
                    point = [pos{1}(1) pos{1}(2)];
                    sep = Geom2d().sep(point, obj.robot.currPos);
                    if(sep < obj.robot.laser.range - obj.robot.map.radius & point ~= prevBox)
                        bestPos = point;
                    end
                end
                if(prevPos == bestPos)
                    prevBox = bestPos;
                    bestPos = obj.closest(prevPos, [path{2}(1) path{2}(2)]);
                end
                %disp(bestPos);
                obj.robot.posTree = [obj.robot.posTree [bestPos(1) bestPos(2)]];
                cla;
                if(obj.showSubdiv)
                    obj.sss.sdiv.displaySubDiv();
                end
                obj.robot.map.showEnv();
                drawnow;
                
                if(obj.showLaser)
                    axis manual;
                    viscircles(obj.robot.currPos, obj.robot.laser.range, 'LineStyle','--');
                    drawnow;
                end
                
                if(obj.showPath)
                    obj.displayCurrPath();
                end
                
                pause(obj.latency);
                set(obj.gui.time, 'String', num2str(toc));
                set(obj.gui.box_visited, 'String', num2str(numBox));
                
                obj.robot.currPos = bestPos;
            end
            obj.robot.map.start = bestPos';
            cla;
            axis manual;
            obj.robot.map.showEnv();
            drawnow;
            if(obj.showLaser)
                axis manual;
                viscircles(obj.robot.currPos, obj.robot.laser.range, 'LineStyle','--');
            end
            if(obj.showPath)
                    obj.displayCurrPath();
            end
            
            obj.robot.map.currPos = obj.robot.map.goal;
            
            
        end
        function point = closest(obj, currPos, nextPos)
            inters = Line(currPos, nextPos).intersecs(currPos, obj.robot.laser.range - obj.robot.map.radius);
            point = inters(2);
            point = point{1};
            if(point == currPos)
                point = inters(1);
                point = point{1};
            end
        end
        
        function displaySubDiv(obj)
            obj.sss.sdiv.displaySubDiv();
        end
        
        function displayCurrPath(obj)
            %access obj.robot.posTree
            axis manual;
            for i=1 : length(obj.robot.posTree)-1
                plot([obj.robot.posTree{i}(1) obj.robot.posTree{i+1}(1)], [obj.robot.posTree{i}(2) obj.robot.posTree{i+1}(2)],'-.or');
                hold on
            end
            hold off
        end
        function displayEnv(obj)
            axis manual;
            obj.robot.map.showEnv();
        end
    end
    
    
    
    methods(Static)
%         function a = test(fname, range)
%             if(nargin == 1)
%                 range = 1;
%             elseif (nargin < 1)
%                 fname = 'env1.txt';
%                 range = 1;
%             end
%             a = RSS(fname, range);
%             a.run();
%         end
    end
    
end

