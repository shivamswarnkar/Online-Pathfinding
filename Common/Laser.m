classdef Laser
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        range;
        env;
        Polygons = {};
    end
    
    methods
        function obj = Laser(environ, rng)
            obj.env = environ;
            obj.range = rng + obj.env.radius;
            obj.Polygons = obj.getPolygons();
       
        end
        
        function pols = getPolygons(obj)
            pols = {};
            for C = obj.env.polygons
                pol = {};
                for i = 1:length(C{1}.X)
                    if i == length(C{1}.X)
                        x = [C{1}.X(i) C{1}.X(1)];
                        y = [C{1}.Y(i) C{1}.Y(1)];
                        p1 = [x(1) y(1)];
                        p2 = [x(2) y(2)];
                    else
                        x = [C{1}.X(i) C{1}.X(i+1)];
                        y = [C{1}.Y(i) C{1}.Y(i+1)];
                        p1 = [x(1) y(1)];
                        p2 = [x(2) y(2)];
                    end
                    line = Line(p1, p2);  %mapshape(x, y, 'Geometry', 'line');
                    pol{length(pol)+1} = line;
                end
                pols{length(pols)+1} = pol;
            end
%             pols{1}{3}
        end
        
        function intersections = scan(obj, pos)
            intersections = {};
            interLineSegs = {};
            for C = obj.Polygons
%                 C{1}
                lines = {};
                for i = 1:length(C{1})
%                     C{1}{i}
                    x = [C{1}{i}.p1(1) C{1}{i}.p2(1)];
                    y = [C{1}{i}.p1(2) C{1}{i}.p2(2)];
                    line = mapshape(x, y, 'Geometry', 'line');
                    if Geom2d.sep(pos, line) <= obj.range
                        lines{length(lines)+1} = C{1}{i};
                    end
                end
                for i = 1:length(lines)
                    inter = lines{i}.intersecs(pos, obj.range);
                    interLineSegs{length(interLineSegs)+1} = inter;
                end
                seps = {};                
%                 disp('done with pol')
            end
            for i=1:length(interLineSegs)
                x = [double(interLineSegs{i}{1}(1)) double(interLineSegs{i}{2}(1))];
                y = [double(interLineSegs{i}{1}(2)) double(interLineSegs{i}{2}(2))];
                line = mapshape(x, y, 'Geometry', 'line');
                intersections{length(intersections)+1} = mapshape(x, y, 'Geometry', 'line');
            end
          
%             obj.map.polygons = intersections;
%             obj.sss.sdiv.env = obj.map;
%             obj.sss.sdiv.setupRootFeatures();
        end
    end
    
    methods(Static)
        function inters = test( )
            env = Environment('env1.txt');
            rng = 2;
            a = Laser(env, rng);
            pos = a.env.start';
            
            a.scan(pos);
            a.map.showEnv();
           
            a.sss.run();
            %viscircles(pos, a.range, 'LineStyle','--');
        end
    end
    
end

