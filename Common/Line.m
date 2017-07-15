classdef Line
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        p1;
        p2;
        slope;
        intercept;
        type;
    end
    
    methods
        function obj = Line(p1, p2)
            obj.p1 = p1;
            obj.p2 = p2;
            if p1(1) ~= p2(1) && p1(2) ~= p2(2)
                obj.slope = (obj.p1(2) - obj.p2(2)) / (obj.p1(1) - obj.p2(1));
                obj.intercept = p1(2) - obj.p1(1)*obj.slope;
                obj.type = 'normal';
            elseif p1(1) == p2(1) && p1(2) ~= p2(2)
                obj.type = 'vertical';
            elseif p1(1) ~= p2(1) && p1(2) == p2(2) 
                obj.type = 'horizontal';
                obj.slope = 0;
            end
        end
        
        function int = intersecs(obj, pos, radius)
            % Returns intersection points of the circle at position 'pos'
            % and of radius 'radius' and the line including points in the
            % circle
            int = {};
            syms x y;
            eqn1 = (x-pos(1))^2 + (y-pos(2))^2 == (radius)^2;
            if strcmp(obj.type, 'normal')
                eqn2 = obj.slope*x + obj.intercept == y;
            elseif strcmp(obj.type, 'vertical')
                eqn2 = x == obj.p1(1);
            elseif strcmp(obj.type, 'horizontal')
                eqn2 = y == obj.p1(2);
            end
            sol = solve([eqn1, eqn2], [x, y]);
%             disp('solx')
%             sol.x
%             disp('soly')
%             sol.y
            if (sol.x(1) <= max(obj.p1(1), obj.p2(1)) && sol.x(1) >= min(obj.p1(1), obj.p2(1)))...
                && (sol.y(1) <= max(obj.p1(2), obj.p2(2)) && sol.y(1) >= min(obj.p1(2), obj.p2(2)))
                point1 = [double(sol.x(1)) double(sol.y(1))];
                int{length(int)+1} = point1;
%                 disp('here1')
            else
                sep1 = Geom2d.sep(obj.p1, [sol.x(1) sol.y(1)]);
                sep2 = Geom2d.sep(obj.p2, [sol.x(1) sol.y(1)]);
                if min(sep1, sep2) == sep1
                    point1 = obj.p1;
                    int{length(int)+1} = point1;
%                     disp('here2')
                else
                    point1 = obj.p2;
                    int{length(int)+1} = point1;
%                     disp('here3')
                end
            end
            if (sol.x(2) <= max(obj.p1(1), obj.p2(1)) && sol.x(2) >= min(obj.p1(1), obj.p2(1)))...
                && (sol.y(2) <= max(obj.p1(2), obj.p2(2)) && sol.y(2) >= min(obj.p1(2), obj.p2(2)))
                point2 = [double(sol.x(2)) double(sol.y(2))];
                int{length(int)+1} = point2;
%                 disp('here4')
            else
                sep1 = Geom2d.sep(obj.p1, [sol.x(2) sol.y(2)]);
                sep2 = Geom2d.sep(obj.p2, [sol.x(2) sol.y(2)]);
                if min(sep1, sep2) == sep1
                    point1 = obj.p1;
                    int{length(int)+1} = point1;
%                     disp('here6')
                else
                    point1 = obj.p2;
                    int{length(int)+1} = point1;
%                     disp('here7')
                end
            end
        end
    end
    
    methods(Static)
        function x = test( p1, p2 )
            if nargin<1
                p1 = [0 0];
                p2 = [2 2];
            end
            a = Line(p1, p2);
            x = a.intersecs([0 0], 1);
        end
    end
    
end

